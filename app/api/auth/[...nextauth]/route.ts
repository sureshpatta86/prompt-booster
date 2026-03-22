import NextAuth from "next-auth"
import Credentials from "next-auth/providers/credentials"

const nextAuthSecret = process.env.NEXTAUTH_SECRET

if (!nextAuthSecret) {
  throw new Error("Missing NEXTAUTH_SECRET environment variable")
}

export const { handlers, auth } = NextAuth({
  providers: [
    Credentials({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" }
      },
      async authorize(credentials) {
        if (credentials?.email && credentials?.password) {
          return {
            id: "1",
            email: credentials.email as string,
            name: "Demo User",
          }
        }
        return null
      }
    })
  ],
  },
  session: {
    strategy: "jwt",
  },
  secret: nextAuthSecret,
})

export const { GET, POST } = handlers

export const { GET, POST } = handlers
