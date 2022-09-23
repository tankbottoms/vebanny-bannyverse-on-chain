/* eslint-disable prettier/prettier */
/* eslint-disable node/no-unsupported-features/es-syntax */
import fs from 'fs';
import { resolve } from 'path';
import pako from 'pako';

const CHUNK_SIZE = Math.floor((1024 * 8) / 32); // 24KB

export function chunkDeflate(path: string): { length: number, parts: string[][], inflatedSize: number } {
    const buffer = fs.readFileSync(resolve(__dirname, '..', path));
    const compressed = pako.deflateRaw(buffer, { level: 9 });

    return { ...chunkBuffer(Buffer.from(compressed)), inflatedSize: buffer.length };
}

export function chunkAsset(path: string): { length: number, parts: string[][] } {
    const buffer = fs.readFileSync(resolve(__dirname, '..', path));

    return chunkBuffer(buffer);
}

function chunkBuffer(buffer: Buffer) {
    const arrayBuffer32 = bufferTo32ArrayBuffer(buffer);

    const parts: string[][] = [];
    for (let i = 0; i < arrayBuffer32.length; i += CHUNK_SIZE) {
        parts.push(arrayBuffer32.slice(i, i + CHUNK_SIZE));
    }

    return { length: buffer.length, parts };
}

export function chunkString(value: string): string[] {
    const buffer = Buffer.from(value);
    const arrayBuffer32 = bufferTo32ArrayBuffer(buffer);

    return arrayBuffer32;
}

export function reconstituteString(bytes: string[]) {
    let buffer = Buffer.from('');

    for (const part of bytes) {
        buffer = Buffer.concat([buffer, Buffer.from(part.slice(2), 'hex')]);
    }

    return buffer.toString('utf8').replace(/\0/g, '');
}

export function smallIntToBytes32(value: number): string {
    return '0x' + ('0000000000000000000000000000000000000000000000000000000000000000' + (value).toString(16)).slice(-64);
}

export function bufferToArrayBuffer(buffer: Buffer) {
    return Array.from(buffer);
}

/**
 * @param Buffer buffer
 * @returns string[] hexStringArray
 */
export function bufferTo32ArrayBuffer(buffer: Buffer) {
    const arrayBuffer = Array.from(buffer);
    const uint256ArrayBuffer: string[] = [];

    for (let i = 0; i < arrayBuffer.length; i++) {
        if (uint256ArrayBuffer.length === 0 || uint256ArrayBuffer[uint256ArrayBuffer.length - 1].length >= 64) uint256ArrayBuffer.push('');
        uint256ArrayBuffer[uint256ArrayBuffer.length - 1] += (arrayBuffer[i] || 0).toString(16).padStart(2, '0');
    }

    for (let i = 0; i < uint256ArrayBuffer.length; i++) {
        uint256ArrayBuffer[i] = '0x' + uint256ArrayBuffer[i].padEnd(64, '0');
    }
    return uint256ArrayBuffer;
}

/**
 * Returns formatted hrtime result. If start param is present, returns time since then in the first element of the array in terms of millis. If the start param is not present, returns raw hrtime output for later use.
 * 
 * @param start Time pair from process.hrtime
 */
export function mark(start?: [number, number]): [number, number] {
    if (!start) {
        return process.hrtime();
    }

    const end = process.hrtime(start);
    return [Math.round((end[0] * 1000) + (end[1] / 1000000)), 0];
}

export function formatMills(millis: number): string {
    const secs = millis / 1000;
    const mins = secs / 60;

    if (secs < 5) {
        return `${millis}ms`;
    }

    if (secs < 91) {
        return `${secs}s`;
    }

    return `${Math.ceil(mins)}m`
}
