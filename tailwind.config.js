/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./_layouts/**/*.html",
    "./_includes/**/*.html",
    "./_posts/**/*.md",
    "./*.html",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'ui-monospace', 'SFMono-Regular', 'monospace'],
      },
      colors: {
        bora: '#FEFAE0',
        skyline: '#D4A373',
        ink: '#2F2A20',
        paper: '#E9EDC9',
        line: '#CCD5AE',
        sand: '#FAEDCD',
      },
    },
  },
  plugins: [],
}
