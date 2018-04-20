# Description:
#   Urban dictionary
#
# Commands:
#   hubot define <term> - Defines a word/phrase
#
#
# Author:
#   h.deakin@quidco.com

module.exports = (robot) ->

  robot.respond /define (.+)?/i, (msg) ->
    term = msg.match[1]
    msg.http("http://api.urbandictionary.com/v0/define?term=" + term)
    .get() (err, res, body) ->
      response = JSON.parse(body)
      for result, i in response.list
        str = "*" + result.word + "*\n"
        str += ">" + result.definition.replace(/(?:\r\n|\r|\n)/g, "\n>") + "\n\n"
        str += "\n>_" + result.example.replace(/(?:\r\n|\r|\n)/g, "_\n>_") + " _\n\n"
        str += "Related: " + response.tags.join(", ")
        str = str.replace(/__/g, "")
        return msg.send str
