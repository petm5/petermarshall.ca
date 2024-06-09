const markdown = require('markdown-it')({
  html: true,
  breaks: false,
  linkify: true,
})
.use(require('markdown-it-attrs'))
.use(require("markdown-it-anchor"))

const Image = require('@11ty/eleventy-img')

markdown.renderer.rules.image = (tokens, idx, options, env, self) => {
  const token = tokens[idx]
  return generateImage(token.attrGet('src'), token.content, token.attrGet('title'))
}

function generateImage (imgSrc, imgAlt = "", imgTitle = "") {
  const htmlOpts = {
    title: imgTitle,
    alt: imgAlt,
    loading: 'lazy',
    decoding: 'async'
  }

  const imgOpts = {
    widths: [144, 240, 460, 580, 768, "auto"],
    formats: ['avif'],
    urlPath: '/assets/img/',
    outputDir: './_site/assets/img/'
  }

  Image(imgSrc, imgOpts)
  const metadata = Image.statsSync(imgSrc, imgOpts)

  const generated = Image.generateHTML(metadata, {
    sizes: '(max-width: 768px) 100vw, 768px',
    ...htmlOpts
  })

  return generated
}

module.exports = function(eleventyConfig) {
  eleventyConfig.setLibrary('md', markdown)
  eleventyConfig.addPassthroughCopy("main.css")
  eleventyConfig.addPassthroughCopy("favicon.ico")
  eleventyConfig.addPassthroughCopy("icons")
  eleventyConfig.addPassthroughCopy("manifest.json")
  eleventyConfig.addPassthroughCopy("app.js")
  eleventyConfig.addPassthroughCopy("sw.js")
  eleventyConfig.addPassthroughCopy("fonts")
  eleventyConfig.addShortcode('image', generateImage)
  eleventyConfig.addFilter("postDate", dateObj => {
    return new Date(dateObj).toLocaleString("en-US", {
      dateStyle: "medium"
    })
  })
	eleventyConfig.addFilter("getAllTags", collection => {
		let tagSet = new Set()
		for(let item of collection) {
			(item.data.tags || []).forEach(tag => tagSet.add(tag))
		}
		return Array.from(tagSet)
	})
	eleventyConfig.addFilter("filterTagList", function filterTagList(tags) {
		return (tags || []).filter(tag => ["all", "nav", "post", "posts"].indexOf(tag) === -1)
	})
	eleventyConfig.addCollection('posts', collection => {
    return [...collection.getFilteredByGlob('./blog/*.md')].reverse()
  })
};
