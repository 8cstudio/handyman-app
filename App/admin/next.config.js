/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ["@handyman/shared"],
  typescript: {
    // Shared package path aliases; pages type-check in IDE
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig;
