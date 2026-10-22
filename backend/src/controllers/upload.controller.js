const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const UPLOAD_DIR = path.join(__dirname, '..', '..', 'uploads');
const ALLOWED_TYPES = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/gif': 'gif',
};
const MAX_BYTES = 8 * 1024 * 1024; // 8MB

/**
 * POST /api/upload/image
 * Body: { "image": "data:image/png;base64,...." } or raw base64 string in
 * { "imageBase64": "...", "mimeType": "image/png" }
 * Returns: { "imageUrl": "<absolute-or-relative-url>" }
 */
exports.uploadImage = async (req, res) => {
  try {
    let { image, imageBase64, mimeType } = req.body;
    let base64Data = image || imageBase64;

    if (!base64Data || typeof base64Data !== 'string') {
      return res.status(400).json({ message: 'No image data provided' });
    }

    // Strip data URI prefix if present
    const dataUriMatch = base64Data.match(/^data:(image\/[\w.+-]+);base64,(.+)$/s);
    if (dataUriMatch) {
      mimeType = mimeType || dataUriMatch[1];
      base64Data = dataUriMatch[2];
    }

    mimeType = (mimeType || 'image/jpeg').toLowerCase();
    const ext = ALLOWED_TYPES[mimeType];
    if (!ext) {
      return res
        .status(415)
        .json({ message: `Unsupported image type: ${mimeType}` });
    }

    const buffer = Buffer.from(base64Data, 'base64');
    if (!buffer.length) {
      return res.status(400).json({ message: 'Invalid base64 image data' });
    }
    if (buffer.length > MAX_BYTES) {
      return res.status(413).json({ message: 'Image too large (max 8MB)' });
    }

    // Ensure upload dir exists
    const subDir = 'images';
    const dir = path.join(UPLOAD_DIR, subDir);
    fs.mkdirSync(dir, { recursive: true });

    const filename = `${Date.now()}-${crypto.randomBytes(8).toString('hex')}.${ext}`;
    fs.writeFileSync(path.join(dir, filename), buffer);

    // Build URL reachable by the client (relative path)
    const imageUrl = `/uploads/${subDir}/${filename}`;

    return res.status(201).json({ imageUrl });
  } catch (error) {
    console.error('Image upload error:', error);
    return res.status(500).json({ message: 'Failed to upload image' });
  }
};
