const markdown = require('markdown-it')({
  html: true,
  breaks: false,
  linkify: true,
})
.use(require('markdown-it-attrs'))
.use(require("markdown-it-anchor"))

const { eleventyImageTransformPlugin } = require("@11ty/eleventy-img");

const htmlmin = require('html-minifier');

const CleanCSS = require("clean-css");
const cssmin = new CleanCSS({});

module.exports = function(eleventyConfig) {
  eleventyConfig.setLibrary('md', markdown)
  eleventyConfig.addPassthroughCopy("src/main.css")
  eleventyConfig.addPassthroughCopy("src/assets")
  eleventyConfig.addPassthroughCopy({"src/assets/logo.png": "assets/favicon.png"})
  eleventyConfig.addPassthroughCopy({"src/assets/logo-transparent.svg": "assets/logo-transparent.svg"})
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
  eleventyConfig.addTransform('htmlmin', function(content, outputPath) {
  	if (!outputPath.endsWith('.html')) return content;

  	return htmlmin.minify(content, {
  		useShortDoctype: true,
  		removeComments: false,
  		collapseWhitespace: true
  	})
  })
  eleventyConfig.addFilter('cssmin', function(code) {
  	return cssmin.minify(code).styles
  })
  eleventyConfig.addGlobalData('gitRev', (process.env.GIT_REVISION || process.env.CF_PAGES_COMMIT_SHA).substr(0, 7))
  return {
  	dir: {
      input: 'src',
    },
  };
};
