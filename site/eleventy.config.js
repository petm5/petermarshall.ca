const markdown = require('markdown-it')({
  html: true,
  breaks: false,
  linkify: true,
})
.use(require('markdown-it-attrs'))
.use(require("markdown-it-anchor"))

const { eleventyImageTransformPlugin } = require("@11ty/eleventy-img");

module.exports = function(eleventyConfig) {
  eleventyConfig.setLibrary('md', markdown)
  eleventyConfig.addPassthroughCopy("src/main.css")
  eleventyConfig.addPassthroughCopy("src/assets")
  eleventyConfig.addPassthroughCopy({"src/assets/logo.png": "favicon.png"})
  eleventyConfig.addPlugin(eleventyImageTransformPlugin, {
		extensions: "html",
    widths: ["auto"],
    formats: ['avif'],
    urlPath: '/assets/',
    widths: [144, 240, 460, 768, 1024],
		defaultAttributes: {
			loading: "lazy",
			decoding: "async",
			sizes: "(max-width: 768px) 100vw, 768px"
		},
  })
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
    return [...collection.getFilteredByGlob('./src/blog/*.md')].reverse()
  })
  return {
  	dir: {
      input: 'src',
    },
  };
};
