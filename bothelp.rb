require 'discordrb'

bot = Discordrb::Commands::CommandBot.new(
  token: 'MzcwNzAyNjQ5MjQ4NDQ4NTEy.DMq7Rg.hDyzdJYpXqFdWNczSgW9LV06wfw', 
  client_id: 370702649248448512,
  prefix: '-'
)
puts "This bot's invite URL is #{bot.invite_url}."
# cd \Ruby24-x64\lib\ruby\gems\2.4.0\gems
# --------------------FILE I/O--------------------------------------------
contests_raw = [
  "mmc1_raw.txt",
  "mmc2_raw.txt",
  "mmc3_raw.txt"
]
def parse(file)
  temp = []
  IO.foreach(file){|line| temp.push(line.strip.split("\t"))}
  arr = []
  for i in 0...temp.length
    arr[i] = {:rank => temp[i][0].to_i, :name => temp[i][1]}
  end
  return arr
end

def process(contests_raw)
  rankings = []
  for i in 0...contests_raw.length
    rankings[i] = parse(contests_raw[i])
  end
  return rankings
end
rankings = process(contests_raw) # rankings is array of array of hash
# -----------------UTILITY METHODS-----------------------------------------
def channel_send(id)
  return "<##{id}>"
end
# --------------------VARIABLES--------------------------------------------
welcome = 201862327937662977
announcements = 182651662257750016
general = 182648867534274564
botprovinggrounds = 323486727081820161
mmc_threads = []
mmc_threads[0] = "https://osu.ppy.sh/forum/t/493507"
mmc_threads[1] = "https://osu.ppy.sh/forum/t/576613"
mmc_threads[2] = "https://osu.ppy.sh/forum/t/632634"
# --------------------COMMANDS--------------------------------------------
# test(n1, n2) is test
bot.command :test do |event,param1,param2|
  event.respond("#{param1} #{param2} to you too, #{event.user.name}")
end
bot.command :ranking do |event, *username|
  user = username.join(' ')
  if rankings.none?{|contest|
      contest.any?{|entry|
        entry[:name] == user
      }
  }
    event.respond("User #{user} was not found.")
  else
    str = ""
    for i in 0...rankings.length # outer loop iterates through each contest
      match = rankings[i].find{|entry| entry[:name] == user}
      temp = match.nil? ? "" : match[:rank]
      str += "MMC #{i+1} : #{temp}\n"
    end
    event.respond(str)
  end
  return nil
end
# clean(n) prunes n messages in channel, including command line, range 2..100
bot.command :clean do |event, num| # Clean n messages (PERMISSIONS)
  event.channel.prune(num.to_i) if event.user.permission?(:manage_messages)
end
# thread(c) returns MMC c contest results thread
bot.command :thread do |event, contest| # return results thread
  case contest
  when "1"
    event.respond("MMC #{contest} Results thread: #{mmc_threads[contest.to_i-1]}")
  when "2"
    event.respond("MMC #{contest} Results thread: #{mmc_threads[contest.to_i-1]}")
  when "3"
    event.respond("MMC #{contest} Results thread: #{mmc_threads[contest.to_i-1]}")
  else
    event.respond("MMC #{contest} not recognized.")
  end
end
# --------------------EVENTS--------------------------------------------
# results emoji when detecting string with "results"
bot.message(containing: '') do |event| 
  if event.message.to_s.downcase.include?("results")
    str = "results when"
    event.respond(str)
  end
end
# test stuff
bot.mention do |event|
  highlight = "<@#{event.user.id}>, sup"
  message = "lol #{channel_send(botprovinggrounds)}"
  bot.send_message(botprovinggrounds, highlight)
  bot.send_message(botprovinggrounds, message)
end
# welcomes and provides links to newcomers
bot.member_join do |event| # Welcome new users
  
  highlight = "Welcome, <@#{event.user.id}>!"
  message = "Please read all the documents in #{channel_send(welcome)} and check what's going on in #{channel_send(announcements)}."
  bot.send_message(general, highlight)
  bot.send_message(general, message)
end


bot.run