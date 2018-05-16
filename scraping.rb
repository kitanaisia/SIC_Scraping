#!ruby
# -*- coding: utf-8 -*-

require "open-uri"
require "nokogiri"

#================================================================================
#
#================================================================================

TR_LENGTH_MEMBER = 18
TR_LENGTH_MUSIC  = 13

class Member
  attr_accessor :name, :card_no, :id, :skill, :img, :rarity, :birthday, :grade, :piece1, :piece2, :piece3, :piece4, :bonus, :ability, :costume
end

class Music
  attr_accessor :name, :card_no, :id, :skill, :img, :color, :live_p, :score_red, :score_green, :score_blue, :score_common
end

def print_card(card)
  if card.class == Member
    str = "#{card.name}\t#{card.card_no}\t#{card.id}\t#{card.skill}\t#{card.img}\t#{card.rarity}\t#{card.birthday}\t#{card.grade}\t\t#{card.piece1}\t#{card.piece2}\t#{card.piece3}\t#{card.piece4}\t#{card.bonus}\t#{card.ability}\t#{card.costume}" 
    return str
  else card.class == Music
    str = "#{card.name}\t#{card.card_no}\t#{card.id}\t#{card.skill}\t#{card.img}\t#{card.color}\t#{card.live_p}\t#{card.score_red}\t#{card.score_green}\t#{card.score_blue}\t#{card.score_common}"
    return str
  end
end

def get_card_urls(html_text)
  urls = []
  html_text.split("\n").each do |line|
    if line =~ /"\/cardlist\/list\/\?cardno=(.*?)"/
      urls << "http://lovelive-sic.com/cardlist/list/?cardno=#{$1}"
    end
  end

  return urls
end

def name_normalize(name)
  name = name.gsub("　", " ")
  name = "高坂 穂乃果" if name == "高坂穂乃果"
  name = "絢瀬 絵里"   if name == "絢瀬絵里"
  name = "南 ことり"   if name == "南ことり"
  name = "園田 海未"   if name == "園田海未"
  name = "星空 凛"     if name == "星空凛"
  name = "西木野 真姫" if name == "西木野真姫"
  name = "東條 希"     if name == "東條希"
  name = "小泉 花陽"   if name == "小泉花陽"
  name = "矢澤 にこ"   if name == "矢澤にこ"

  return name
end

members = []
musics  = []

# Load html
File.open("urllist.txt").read.split("\n").each do |url|
  html_text = open(url, 'r:utf-8').read

  # Open files
  urls = get_card_urls(html_text)

  urls.each do |url|
    puts url
    html_text = open(url, 'r:utf-8').read
    sleep 1
    doc = Nokogiri::HTML.parse(html_text, nil, "utf-8") 
    card_info = doc.xpath('//div[@class="card-detail"]')

    # 画像の取得
    img_path = card_info.xpath('//p[@class="illust-2"]').at("img").attribute("src").value
    img_url = "http://lovelive-sic.com#{img_path}"

    # その他の情報取得
    trs = card_info.search("tr")

    if trs.length == TR_LENGTH_MEMBER
      member = Member.new
      member.img = img_url

      trs.each do |tr|
        th = tr.at("th")
        td = tr.at("td")

        if td.nil?
          member.name = name_normalize(th.text)
          next
        end

        case th.text
        when "カードNo."; member.card_no = td.text 
        when "ID";        member.id = td.text
        when "誕生日";    member.birthday = td.text
        when "学年";      member.grade = td.text
        when "コスト";    member.rarity = td.text
        when "ピース1";   member.piece1 = td.text
        when "ピース2";   member.piece2 = td.text
        when "ピース3";   member.piece3 = td.text
        when "ピース4";   member.piece4 = td.text
        when "ボーナス";  member.bonus = td.text
        when "特技";      member.ability = td.text
        when "衣装";      member.costume = td.text
        when "スキル";    member.skill = td.text.gsub("\n", " ")
        else 
        end
      end

      members << member
    elsif trs.length == TR_LENGTH_MUSIC
      music = Music.new
      music.img = img_url

      trs.each do |tr|
        th = tr.at("th")
        td = tr.at("td")

        if td.nil?
          music.name = th.text
          next
        end

        case th.text
        when "カードNo.";    music.card_no = td.text
        when "ID";           music.id = td.text
        when "枠属性";       music.color = td.text
        when "ライブP";      music.live_p = td.text
        when "赤スコア";     music.score_red = td.text
        when "緑スコア";     music.score_green = td.text
        when "青スコア";     music.score_blue = td.text
        when "共通スコア";   music.score_common = td.text
        when "スキル";       music.skill = td.text.gsub("\n", " ")
        end
      end

      musics << music
    end
  end
end

# CSV Output
members_csv = File.open("member.csv", "w")
members.each do |member|
  members_csv.puts print_card(member)
end
members_csv.close

musics_csv = File.open("music.csv", "w")
musics.each do |music|
  musics_csv.puts print_card(music)
end
musics_csv.close
