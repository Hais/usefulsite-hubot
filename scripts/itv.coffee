async = require 'async'
cheerio = require 'cheerio'
moment = require 'moment'

module.exports = (robot) ->

    scrape = (date, cb) -> 
        robot.http("https://www.itv.com/hub/tv-guide/#{ date }").get() (err, res, body) ->
            return cb err if err?
            $ = cheerio.load body
            cb null, {
                date: date
                channels: 
                    $('li[data-guide-type=channel]').map () ->
                        name: $(this).find($('h3')).text()
                        listings: 
                            $(this).find($('li .guide__item')).map () ->
                                title: $(this).find($('.guide__title')).text()
                                time: $(this).find($('.guide__time')).text()
                            .get()
                    .get()
            }

    robot.respond /is (.+)? on itv/i, (msg) ->
        find = msg.match[1].toLowerCase()
        msg.send "Checking if '#{find}' is on ITV..."
        dates = (moment().add(i, 'days').format("YYYY-MM-DD") for i in [0...7])
        async.map dates, scrape, (err, results) ->
            return msg.send "FAIL" if err?
            for day in results
                for channel in day.channels
                    for listing in channel.listings when listing.title.toLowerCase().indexOf(find) >= 0
                        msg.send "#{listing.title} is on #{channel.name} at #{listing.time}, #{day.date}"
