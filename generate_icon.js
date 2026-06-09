const { createCanvas } = require('canvas');
const fs = require('fs');
const path = require('path');

// Render the Shekify icon programmatically at 1024x1024
const SIZE = 1024;
const canvas = createCanvas(SIZE, SIZE);
const ctx = canvas.getContext('2d');

// Background gradient (radial)
const bgGrad = ctx.createRadialGradient(SIZE/2, SIZE/2, 0, SIZE/2, SIZE/2, SIZE*0.7);
bgGrad.addColorStop(0, '#16161E');
bgGrad.addColorStop(1, '#0F0F12');

// Rounded rect background
const r = (112/512) * SIZE;
ctx.beginPath();
ctx.moveTo(r, 0);
ctx.lineTo(SIZE - r, 0);
ctx.quadraticCurveTo(SIZE, 0, SIZE, r);
ctx.lineTo(SIZE, SIZE - r);
ctx.quadraticCurveTo(SIZE, SIZE, SIZE - r, SIZE);
ctx.lineTo(r, SIZE);
ctx.quadraticCurveTo(0, SIZE, 0, SIZE - r);
ctx.lineTo(0, r);
ctx.quadraticCurveTo(0, 0, r, 0);
ctx.closePath();
ctx.fillStyle = bgGrad;
ctx.fill();

// Scale factor from 512 to SIZE
const s = SIZE / 512;

// Inner glow circle
ctx.globalAlpha = 0.08;
ctx.beginPath();
ctx.arc(256*s, 256*s, 140*s, 0, Math.PI*2);
ctx.fillStyle = '#6366F1';
ctx.fill();
ctx.globalAlpha = 1.0;

// Wave gradient
const waveGrad = ctx.createLinearGradient(0, 0, SIZE, SIZE);
waveGrad.addColorStop(0, '#818CF8');
waveGrad.addColorStop(0.5, '#6366F1');
waveGrad.addColorStop(1, '#4F46E5');

// Neon glow (shadow)
ctx.shadowColor = '#6366F1';
ctx.shadowBlur = 24 * s;

// S-curve path
ctx.beginPath();
ctx.moveTo(360*s, 160*s);
ctx.bezierCurveTo(320*s, 120*s, 220*s, 120*s, 180*s, 170*s);
ctx.bezierCurveTo(140*s, 220*s, 160*s, 260*s, 210*s, 280*s);
ctx.lineTo(302*s, 316*s);
ctx.bezierCurveTo(360*s, 340*s, 370*s, 390*s, 332*s, 440*s);
ctx.bezierCurveTo(282*s, 500*s, 190*s, 480*s, 152*s, 432*s);
ctx.strokeStyle = waveGrad;
ctx.lineWidth = 32 * s;
ctx.lineCap = 'round';
ctx.lineJoin = 'round';
ctx.stroke();

// Dot highlights
ctx.shadowBlur = 0;

ctx.beginPath();
ctx.arc(180*s, 170*s, 8*s, 0, Math.PI*2);
ctx.fillStyle = 'rgba(255,255,255,0.9)';
ctx.fill();

ctx.beginPath();
ctx.arc(256*s, 243*s, 6*s, 0, Math.PI*2);
ctx.fillStyle = 'rgba(129,140,248,0.7)';
ctx.fill();

ctx.beginPath();
ctx.arc(332*s, 440*s, 8*s, 0, Math.PI*2);
ctx.fillStyle = 'rgba(255,255,255,0.9)';
ctx.fill();

// Save to PNG
const out = path.join(__dirname, 'assets', 'logo.png');
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync(out, buffer);
console.log('Icon saved to', out);
