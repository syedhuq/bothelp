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
no_perm = "You do not have permission to access this command!"
mmc_threads = [
  "https://osu.ppy.sh/forum/t/632634",
  "https://osu.ppy.sh/forum/t/576613",
  "https://osu.ppy.sh/forum/t/632634"
]
help_public = [
  "`-help (show\_admin)` : Shows how to use bothelp commands. If called with the argument 'admin', will display admin commands as well. ex. `-help` or `-help admin`",
  "`-ranking <user>` : Returns the user's rank in all past contests. Is not case-sensitive. ex. `-ranking Zexous`",
  "`-thread <n>` : Links results thread for given contest. Include only the number. ex. `-thread 3`"
]
help_admin = [
  "`-clear <n>` : Removes the last n lines (including command line) from chat, bounded 2-100. ex. `-clear 5`",
  "`-setname <user> (name)` : Set's the target user's nick, or resets it if only one argument is given. Both arguments are case-sensitive. Represent spaces with underscore. ex. `-setname Smoothie_World sw`",
  "`-setrole <user> <role>` : Set's the target user's role. The user argument is case-sensitive. ex. `-setrole Ongaku Contestants`",
  "`-clearrole <role>` : Removes all members from this role. ex. `-clearrole Contestants`"
]
# --------------------COMMANDS--------------------------------------------
# help(admin=false) returns info for all bot commands, and admin commands too if desired
bot.command :help, min_args: 0, max_args: 1 do |event, admin|
  event.respond("**Public Commands:**\n" + help_public.join("\n"))
  event.respond("**Admin Commands:**\n" + help_admin.join("\n")) if admin.downcase == "admin"
end

# ranking(user) returns the given user's rankings in all previous MMC
bot.command :ranking, min_args: 1 do |event, *username|
  user = username.join(' ')
  if rankings.none?{|contest|
      contest.any?{|entry|
        entry[:name].downcase == user.downcase
      }
  }
    event.respond("User #{user} was not found.")
  else
    str = ""
    for i in 0...rankings.length # outer loop iterates through each contest
      match = rankings[i].find{|entry| entry[:name].downcase == user.downcase}
      if match.nil?
        temp = ""
      else
        cased_name ||= match[:name]
        temp = match[:rank]
      end
      str += "MMC #{i+1} : #{temp}\n"
    end
    event.respond("Displaying rankings for #{cased_name}:\n" + str)
  end
  return nil
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

# clean(n) prunes n messages in channel, including command line, range 2..100
bot.command :clear, required_permissions: [:manage_messages], permission_message: no_perm, min_args: 1 do |event, num| # Clean n messages (PERMISSIONS)
  event.channel.prune(num.to_i) if event.user.permission?(:manage_messages)
end

# setname(user, nick=nil) sets the given user's nick to the nick argument
bot.command :setname, required_permissions: [:manage_nicknames], permission_message: no_perm, min_args: 1, max_args: 2 do |event, user, nick|
  user_spaced = user.gsub(/[_]/, ' ')
  nick_spaced = nick.gsub(/[_]/, ' ')
  space = false # shoddy workaround: search for name, then search for name with _ as spaces, if they're spaces we think that way from now on
  people = event.server.members()
  loc = nil
  for i in 0...people.length
    if people[i].display_name() == user
      loc = i
    elsif people[i].display_name() == user_spaced
      loc = i
      space = true
    end
  end
  if loc.nil?
    if space
      str = "User #{user_spaced} not found."
    else
      str = "User #{user} not found."
    end
  else
    if space
      str = "User #{people[loc].display_name} was renamed to #{nick_spaced}."
      event.server.member(people[loc].id).nick = nick_spaced
    else
      str = "User #{people[loc].display_name} was renamed to #{nick}."
      event.server.member(people[loc].id).nick = nick
    end
  end
  event.respond(str)
end

# setrole(user, role) sets the given user's role to the role argument
bot.command :setrole, required_permissions: [:manage_roles], permission_message: no_perm, min_args: 2, max_args: 2 do |event, user, role|
  user_spaced = user.gsub(/[_]/, ' ')
  space = false # shoddy workaround: search for name, then search for name with _ as spaces, if they're spaces we think that way from now on
  people = event.server.members()
  loc = nil
  for i in 0...people.length
    if people[i].display_name() == user
      loc = i
    elsif people[i].display_name() == user_spaced
      loc = i
      space = true
    end
  end
  if loc.nil?
    if space
      str = "User #{user_spaced} not found."
    else
      str = "User #{user} not found."
    end
  else
    role_actual = event.server.roles.find{|r| r.name.downcase == role.downcase}
    str = "User #{people[loc].display_name} was given the #{role_actual.name} role."
    event.server.member(people[loc].id).roles = [role_actual]
  end
  event.respond(str)  
end
# clearrole(role) removes all members from this role
bot.command :clearrole, required_permissions: [:manage_roles], permission_message: no_perm, min_args: 1, max_args: 1 do |event, role|
  role_actual = event.server.roles.find{|r| r.name.downcase == role.downcase}
  sum = 0
  event.server.members.each{|person|
    if person.role?(role_actual)
      person.remove_role(role_actual)
      sum += 1
      puts "Removed #{person.display_name} from #{role_actual.name}"
    end
  }
  event.respond("Removed #{sum} members from #{role_actual.name}.")
end
# --------------------EVENTS--------------------------------------------
# welcomes and provides links to newcomers
bot.member_join do |event| # Welcome new users
  
  highlight = "Welcome, <@#{event.user.id}>!"
  message = "Please read all the documents in #{channel_send(welcome)} and check what's going on in #{channel_send(announcements)}."
  bot.send_message(general, highlight)
  bot.send_message(general, message)
end


bot.run