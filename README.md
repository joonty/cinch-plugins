Plugins for Cinch
=================

This repository contains several plugins for the
[Cinch](https://github.com/cinchrb/cinch) framework, which allows
for the easy creation of IRC bots (in ruby).

Usage
-----

First, create a top level file that you'll run to start the bot. This looks something
like this:

```ruby
require "cinch"
require_relative "plugins/word_game"

cinch = Cinch::Bot.new do
  configure do |config|
    config.server = "irc.freenode.net"
    config.channels = ["#cinch-bots"]
    config.nick = "wordgame"
    config.plugins.plugins = [Cinch::WordGame]
  end
end

cinch.start
```

Obviously this will change depending on the channels, bot nickname and plugins that you
enable.

Available plugins
-----------------

This repository currently provides the following plugins:

* **WordGame:** an insanely addictive multiplayer word game

* **EvalIn:** evaluate code using [eval.in](https://eval.in), and output the result

* **LinkTitle:** print out the title of any link posted in the channel

* **TeamTime:** the user asks every other user in the channel whether they want a drink

* **Bitbucket:** a slowly growing toolset relating to bitbucket (currently only pull requests)

Some plugins have configuration, so check each plugin for the description.

License
-------

MIT: see License.txt
