import { db } from './db';
import { users, categories } from './schema';
import bcrypt from 'bcryptjs';
import process from 'process';

async function seed() {
  console.log('🌱 Seeding database...');

  try {
    // Create default categories
    const defaultCategories = await db.insert(categories).values([
      {
        name: 'General',
        description: 'General purpose prompts',
        color: '#3b82f6',
      },
      {
        name: 'Content Creation',
        description: 'Prompts for content generation',
        color: '#10b981',
      },
      {
        name: 'Code Assistant',
        description: 'Programming and development prompts',
        color: '#f59e0b',
      },
      {
        name: 'Analysis',
        description: 'Data analysis and research prompts',
        color: '#8b5cf6',
      },
      {
        name: 'Creative Writing',
    console.log('✅ Created default categories:', defaultCategories.length);

    // Create admin user
    const adminPassword = process.env.SEED_ADMIN_PASSWORD;
    if (!adminPassword) {
      throw new Error('SEED_ADMIN_PASSWORD environment variable is required to seed the admin user');
    }

    const hashedPassword = await bcrypt.hash(adminPassword, 10);
    
    const adminUser = await db.insert(users).values({
      name: 'Admin User',
    // Create admin user
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    const adminUser = await db.insert(users).values({
      name: 'Admin User',
      email: 'admin@promptbooster.com',
      password: hashedPassword,
      role: 'ADMIN',
    }).returning();

    console.log('✅ Created admin user:', adminUser[0].email);

    console.log('🎉 Database seeded successfully!');
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  }
}

if (require.main === module) {
  seed()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

export default seed;
