import { imba } from "vite-plugin-imba";
import { defineConfig } from "vite";
import GithubActionsReporter from "vitest-github-actions-reporter-temp";

export default defineConfig({
  plugins: [imba()],
  define: {
    "import.meta.vitest": "undefined",
  },
  build: {
    rollupOptions: {
      output: {
        entryFileNames: "assets/[name].js",
        assetFileNames: "assets/[name][extname]",
      },
    },
  },
  test: {
    globals: true,
    include: ["**/*.{test,spec}.{imba,js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    includeSource: ["app/**/*.{imba,js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    environment: "jsdom",
    setupFiles: ["./test/setup.imba"],
    reporters: process.env.GITHUB_ACTIONS
      ? new GithubActionsReporter()
      : "default",
  },
});
