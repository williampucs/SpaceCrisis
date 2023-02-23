const defaultSans = [
  // English Fonts
  "Overpass",
  "Roboto",
  "'Helvetica Neue'",
  "Arial",
  "Helvetica",
  "'Noto Sans'",
  // Chinese Fonts, Mac/Win/Linux
  "'PingFang SC'",
  "'Microsoft Yahei'",
  "微软雅黑",
  "'WenQuanYi Micro Hei'",
  // System Fonts
  "system-ui",
  "-apple-system",
  "BlinkMacSystemFont",
  "'Segoe UI'",
  "sans-serif",
  // emoji fonts
  "'Apple Color Emoji'",
  "'Segoe UI Emoji'",
  "'Segoe UI Symbol'",
  "'Noto Color Emoji'",
];

module.exports = {
  theme: {
    container: {
      center: true,
    },
    extend: {
      fontFamily: {
        sans: [...defaultSans],
      },
    },
  },
  plugins: [require("@tailwindcss/typography")],
};
