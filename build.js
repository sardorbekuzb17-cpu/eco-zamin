/**
 * Build script - Production uchun minify qilish
 */
import fs from 'fs';
import path from 'path';
import { minify } from 'terser';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function buildMinified() {
    console.log('🔨 Build boshlandi...');

    try {
        // GreenMarketLib.js ni o'qish
        const libPath = path.join(__dirname, 'src', 'GreenMarketLib.js');
        const code = fs.readFileSync(libPath, 'utf8');

        console.log('📦 Minify qilinmoqda...');

        // Minify qilish
        const result = await minify(code, {
            compress: {
                dead_code: true,
                drop_console: false,
                drop_debugger: true,
                keep_classnames: true,
                keep_fnames: false,
                passes: 2
            },
            mangle: {
                keep_classnames: true,
                keep_fnames: false
            },
            format: {
                comments: false,
                preamble: '/* GreenMarket Library v1.0.0 - Minified */'
            }
        });

        // Minified faylni saqlash
        const minPath = path.join(__dirname, 'src', 'GreenMarketLib.min.js');
        fs.writeFileSync(minPath, result.code, 'utf8');

        // Statistika
        const originalSize = Buffer.byteLength(code, 'utf8');
        const minifiedSize = Buffer.byteLength(result.code, 'utf8');
        const reduction = ((1 - minifiedSize / originalSize) * 100).toFixed(2);

        console.log('✅ Build muvaffaqiyatli tugadi!');
        console.log(`📊 Asl hajm: ${(originalSize / 1024).toFixed(2)} KB`);
        console.log(`📊 Minified hajm: ${(minifiedSize / 1024).toFixed(2)} KB`);
        console.log(`📊 Qisqarish: ${reduction}%`);

    } catch (error) {
        console.error('❌ Build xatosi:', error);
        process.exit(1);
    }
}

// Build ni ishga tushirish
buildMinified();
