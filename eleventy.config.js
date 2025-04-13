import markdownit from 'markdown-it';
import markdownitattrs from 'markdown-it-attrs';
import markdownitanchor from 'markdown-it-anchor';

const markdown = markdownit({
  html: true,
  breaks: false,
  linkify: true,
})
.use(markdownitattrs)
.use(markdownitanchor)

import EleventyVitePlugin from "@11ty/eleventy-plugin-vite";
import { ViteMinifyPlugin } from 'vite-plugin-minify';

import { eleventyImageTransformPlugin } from "@11ty/eleventy-img";

import path from "path";

import { format } from "date-fns";

export default async function(eleventyConfig) {
  eleventyConfig.setLibrary('md', markdown)
  eleventyConfig.addPassthroughCopy("src/assets")
  eleventyConfig.addPassthroughCopy({"src/assets/logo.png": "assets/favicon.png"})
  eleventyConfig.addPassthroughCopy({"src/assets/logo-transparent.svg": "assets/logo-transparent.svg"})
  eleventyConfig.addPlugin(EleventyVitePlugin, {
    viteOptions: {
      appType: "mpa",
      plugins: [
        ViteMinifyPlugin({
          processScripts: ['application/ld+json'],
          removeComments: false
        }),
      ],
      build: {
        assetsInlineLimit: 0,
        rollupOptions: {
          output: {
            assetFileNames: (assetInfo) => {
              const extension = path.extname(assetInfo.name);
              if (['.jpeg', '.png', '.avif', '.webp'].includes(extension)) {
                return 'assets/[name].[ext]';
              }
              return 'assets/[name].[hash].[ext]';
            },
          },
        },
      },
      server: {
        middlewareMode: true,
      },
      resolve: {
        alias: {
          "/node_modules": path.resolve(".", "node_modules"),
        },
      }
    }
	})
  eleventyConfig.addPlugin(eleventyImageTransformPlugin, {
		extensions: "html",
    widths: ["auto"],
    formats: ['avif', 'jpeg'],
    urlPath: '/assets/',
    widths: [240, 460, 768, 1024],
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
  eleventyConfig.addFilter('date', function (date, dateFormat) {
    return format(date, dateFormat)
  })
	eleventyConfig.addCollection('posts', collection => {
    return [...collection.getFilteredByGlob('./src/blog/*.md')].reverse()
  })
  eleventyConfig.addGlobalData('gitRev', (process.env.GIT_REVISION || process.env.CF_PAGES_COMMIT_SHA || "dev").substr(0, 7))
  return {
  	dir: {
      input: 'src',
    },
  };
};
