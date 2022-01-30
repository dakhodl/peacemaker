const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*'
  ],
  theme: {
    colors: {
      'white': colors.white,
      'black': colors.black,
      'gray': colors.gray,
      'blue': colors.blue,
      'indigo': colors.indigo,
      'sky': colors.sky,
      'rose': colors.rose,
      'green': colors.green,
      'yellow': colors.yellow,
    },
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      height: {
        'screen-w-nav': '88vh',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
