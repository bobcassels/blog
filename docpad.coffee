# DocPad Configuration File
# http://docpad.org/docs/config

cheerio = require('cheerio')
url = require('url')
path = require('path')

# Define the DocPad Configuration
docpadConfig = {
  srcPath: ''
  ignorePaths: [path.join(process.cwd(), 'out')]
  templateData:
    # Specify some site properties
    site:
      # The production url of our website
      url: "http://blog.pencilcode.net"

      # The default title of our website
      title: "Pencil Code Blog"

      # The website author's name
      author: "Pencil Code Foundation"

      # The website author's email
      email: "info@pencilcode.net"

      # cache-busting timestamp
      timestamp: new Date().getTime()


    # -----------------------------
    # Helper Functions

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
      # if we have a document title, then we should use that and suffix the site's title onto it
      if @document.title
        "#{@document.title} - #{@site.title}"
        # if our document does not have it's own title, then we should just use the site's title
      else
        @site.title

    getPageUrlWithHostname: ->
      "#{@site.url}#{@document.url}"

    getIdForDocument: (document) ->
      hostname = url.parse(@site.url).hostname
      date = document.date.toISOString().split('T')[0]
      path = document.url
      "tag:#{hostname},#{date},#{path}"

    fixLinks: (content) ->
      if not content? then return ''
      baseUrl = @site.url
      regex = /^(http|https|ftp|mailto):/

      $ = cheerio.load(content)
      $('img').each ->
        $img = $(@)
        src = $img.attr('src')
        $img.attr('src', baseUrl + src) unless regex.test(src)
      $('a').each ->
        $a = $(@)
        href = $a.attr('href')
        $a.attr('href', baseUrl + href) unless regex.test(href)
      $.html()

    moment: require('moment')

    # Discus.com settings
    disqusShortName: 'pencilcode'

    # Google+ settings
    # googlePlusId: '?????'

    getTagUrl: (tag) ->
      slug = tag.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')
      "/tags/#{slug}/"

  collections:
    posts: ->
      @getCollection('documents').findAllLive({relativeDirPath: 'posts'}, [date: -1])

    cleanurls: ->
      @getCollection('html').findAllLive(skipCleanUrls: $ne: true)

  environments:
    development:
      collections:
        posts: ->
          @getCollection('documents').findAllLive({relativeDirPath: {'$in' : ['posts', 'drafts']}}, [relativeDirPath: 1,  date: -1])

  regenerateDelay: 1000

  watchOptions:
    interval: 2007
    catchupDelay: 2000
    preferredMethods: ['watchFile','watch']

  plugins:
    tags:
      findCollectionName: 'posts'
      extension: '.html'
      injectDocumentHelper: (document) ->
        document.setMeta(
          layout: 'tags'
        )
    dateurls:
      cleanurl: true
      trailingSlashes: true
      keepOriginalUrls: false
      collectionName: 'posts'
      dateIncludesTime: true
    paged:
      cleanurl: true
      startingPageNumber: 2
    cleanurls:
      trailingSlashes: true
      collectionName: 'cleanurls'
}

# Export the DocPad Configuration
module.exports = docpadConfig
