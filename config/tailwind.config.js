const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          '"ヒラギノ角ゴ ProN"',
          '"Hiragino Kaku Gothic ProN"',
          '"ヒラギノ角ゴ Pro"',
          '"Hiragino Kaku Gothic Pro"',
          '"游ゴシック"',
          '"Yu Gothic"',
          'YuGothic',
          'メイリオ',
          'Meiryo',
          '"ＭＳ ゴシック"',
          '"MS Gothic"',
          ...defaultTheme.fontFamily.sans
        ],
      },
      fontSize: {
        base: '17px',
      },
      lineHeight: {
        normal: '1.6',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
