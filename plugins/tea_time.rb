require 'cinch'
require 'set'

class Cinch::Plugins::TeaTime
  include Cinch::Plugin

  match(/(cuppa|tea|coffee|drink)/)

  def execute(m, word)
    m.reply "#{nicks_for_channel(m.channel)}: would you like a #{word}? #{m.user} is making them."
  end

  def nicks_for_channel(channel)
    ignore = config[:ignore_nicks].to_a || []
    ignore << bot.nick
    (channel.users.keys - ignore).join(", ")
  end
end
