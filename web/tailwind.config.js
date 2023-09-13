const colors = {
    carbon: {
        100: 'rgb(48, 48, 48)',
        200: 'rgb(42, 42, 42)',
        300: 'rgb(36, 36, 36)',
        400: 'rgb(30, 30, 30)',
        500: 'rgb(24, 24, 24)',
        600: 'rgb(20, 20, 20)',
        700: 'rgb(16, 16, 16)',
        800: 'rgb(12, 12, 12)',
        900: 'rgb(8, 8, 8)',
    },
}

/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
        './pages/**/*.{js,ts,jsx,tsx,mdx}',
        './components/**/*.{js,ts,jsx,tsx,mdx}',
        './app/**/*.{js,ts,jsx,tsx,mdx}',
    ],
    theme: {
        extend: {
            colors,
            borderColor: colors.carbon['300']
        },
    },
    plugins: [],
}
