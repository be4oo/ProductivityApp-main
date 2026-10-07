#!/usr/bin/env python3
"""Generate Blitzit's original dancing-blob GIF using only Python's stdlib.

No downloaded media, fonts, image libraries, or runtime dependencies. Run from
any directory: python3 scripts/generate_completion_gif.py
The 32 hand-drawn pixel-art frames make one 2.56-second seamless dance loop.
"""

import math
from pathlib import Path
import struct

WIDTH, HEIGHT, FRAME_COUNT = 192, 128, 32
PALETTE = [
    (32, 36, 44),    # 0: matches the celebration card
    (20, 22, 27),    # 1: outlines, sunglasses
    (184, 242, 128), # 2: lime mascot
    (143, 203, 99),  # 3: body shading
    (232, 255, 203), # 4: highlight
    (244, 246, 250), # 5: teeth and sneakers
    (189, 160, 255), # 6: lilac
    (255, 209, 102), # 7: gold
    (110, 220, 224), # 8: sunglass glints
    (244, 128, 172), # 9: tongue and party hat
    (46, 52, 61),   # 10: floor shadow
] + [(32, 36, 44)] * 21


class Canvas:
    def __init__(self):
        self.pixels = bytearray(WIDTH * HEIGHT)

    def ellipse(self, cx, cy, rx, ry, color):
        for y in range(max(0, math.floor(cy - ry)),
                       min(HEIGHT, math.ceil(cy + ry) + 1)):
            for x in range(max(0, math.floor(cx - rx)),
                           min(WIDTH, math.ceil(cx + rx) + 1)):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1:
                    self.pixels[y * WIDTH + x] = color

    def line(self, points, color, width=3):
        for (ax, ay), (bx, by) in zip(points, points[1:]):
            count = max(1, math.ceil(math.hypot(bx - ax, by - ay) * 2))
            for step in range(count + 1):
                self.ellipse(ax + (bx - ax) * step / count,
                             ay + (by - ay) * step / count,
                             width / 2, width / 2, color)

    def polygon(self, points, color):
        for y in range(max(0, math.floor(min(p[1] for p in points))),
                       min(HEIGHT, math.ceil(max(p[1] for p in points)) + 1)):
            intersections = []
            for (ax, ay), (bx, by) in zip(points, points[1:] + points[:1]):
                if (ay <= y < by) or (by <= y < ay):
                    intersections.append(ax + (y - ay) * (bx - ax) / (by - ay))
            intersections.sort()
            for left, right in zip(intersections[::2], intersections[1::2]):
                for x in range(max(0, math.ceil(left)),
                               min(WIDTH, math.floor(right) + 1)):
                    self.pixels[y * WIDTH + x] = color


def draw_frame(index):
    canvas = Canvas()
    phase = index * math.tau / FRAME_COUNT
    sway = math.sin(phase)
    bounce = (1 - math.cos(phase * 2)) / 2
    cx, cy = 96 + sway * 9, 67 - bounce * 7
    angle = sway * 0.16

    def point(x, y):
        return (cx + x * math.cos(angle) - y * math.sin(angle),
                cy + x * math.sin(angle) + y * math.cos(angle))

    def poly(points, color):
        canvas.polygon([point(x, y) for x, y in points], color)

    def stroke(points, color, width=3):
        canvas.line([point(x, y) for x, y in points], color, width)

    canvas.ellipse(96, 113, 41 - bounce * 5, 5, 10)

    # Slow, orbiting sparkles: cheerful without flashes or strobing.
    for number in range(5):
        t = phase + number * math.tau / 5
        x, y = 96 + math.cos(t) * 66, 61 + math.sin(t) * 39
        canvas.line([(x - 3, y), (x + 3, y)], 6 + number % 4, 2)
        canvas.line([(x, y - 3), (x, y + 3)], 6 + number % 4, 2)

    # Noodle arms: one finger points to the disco, the other does its best.
    for side in [-1, 1]:
        hand_y = -19 - side * sway * 17
        stroke([(side * 26, 2), (side * 42, -5), (side * 46, hand_y)], 1, 7)
        stroke([(side * 26, 2), (side * 42, -5), (side * 46, hand_y)], 2, 3)
        hand = point(side * 46, hand_y)
        canvas.ellipse(*hand, 5, 5, 2)
        stroke([(side * 46, hand_y), (side * 46, hand_y - 8)], 2, 3)

    # Oversized sneakers alternate an extremely serious high kick.
    for side in [-1, 1]:
        kick = max(0, side * sway)
        foot_x, foot_y = side * (19 + kick * 19), 42 - kick * 15
        stroke([(side * 13, 23), (side * 17, 35), (foot_x, foot_y)], 1, 7)
        foot = point(foot_x + side * 3, foot_y)
        canvas.ellipse(*foot, 12, 6, 1)
        canvas.ellipse(foot[0], foot[1] - 1, 10, 4, 5)
        canvas.line([(foot[0] - 8, foot[1] + 3),
                     (foot[0] + 8, foot[1] + 3)], 6, 2)

    # A wobbly, squash-and-stretch jellybean silhouette.
    for radius, color in [(1, 1), (0.91, 2)]:
        outline = []
        for step in range(48):
            t = step * math.tau / 48
            wobble = 1 + 0.045 * math.sin(t * 3 + phase * 2)
            outline.append((math.cos(t) * (33 + bounce * 2) * radius * wobble,
                            math.sin(t) * (32 - bounce * 2) * radius * wobble))
        poly(outline, color)
    stroke([(-24, 8), (-20, 18), (-12, 22)], 3, 4)
    stroke([(-20, -20), (-14, -24), (-7, -25)], 4, 3)

    # Tiny party hat plus enormous cool-guy sunglasses.
    poly([(-8, -29), (1, -45), (10, -28)], 1)
    poly([(-5, -30), (1, -41), (7, -29)], 9)
    canvas.ellipse(*point(1, -44), 3, 3, 7)
    stroke([(-28, -10), (28, -10)], 1, 4)
    for x in [-14, 14]:
        poly([(x - 11, -13), (x + 10, -13),
              (x + 8, 0), (x - 7, 2), (x - 11, -3)], 1)
        stroke([(x - 5, -9), (x + 1, -9)], 8, 2)
    poly([(-11, 9), (11, 9), (9, 18), (2, 23), (-6, 21)], 1)
    poly([(-8, 10), (8, 10), (6, 14), (-6, 14)], 5)
    poly([(-2, 19), (6, 17), (7, 20), (2, 22)], 9)
    return canvas.pixels


def lzw(pixels):
    """GIF LZW codes and bit packing, with bounded 12-bit dictionaries."""
    clear, end = 32, 33
    table = {bytes([i]): i for i in range(clear)}
    next_code = end + 1
    codes = [clear]
    word = b''
    for value in pixels:
        char = bytes([value])
        if word + char in table:
            word += char
            continue
        codes.append(table[word])
        if next_code < 4096:
            table[word + char] = next_code
            next_code += 1
        else:
            codes.append(clear)
            table = {bytes([i]): i for i in range(clear)}
            next_code = end + 1
        word = char
    if word:
        codes.append(table[word])
    codes.append(end)

    output = bytearray()
    bits = bit_count = 0
    width, next_code, previous = 6, end + 1, False
    for code in codes:
        bits |= code << bit_count
        bit_count += width
        while bit_count >= 8:
            output.append(bits & 255)
            bits >>= 8
            bit_count -= 8
        if code == clear:
            width, next_code, previous = 6, end + 1, False
        elif code != end:
            if previous:
                next_code += 1
                if next_code == 1 << width and width < 12:
                    width += 1
            previous = True
    if bit_count:
        output.append(bits & 255)
    return output


def main():
    output = bytearray(b'GIF89a')
    output.extend(struct.pack('<HHBBB', WIDTH, HEIGHT, 0xF4, 0, 0))
    output.extend(value for rgb in PALETTE for value in rgb)
    output.extend(b'\x21\xff\x0bNETSCAPE2.0\x03\x01\x00\x00\x00')
    for index in range(FRAME_COUNT):
        # Restore each full frame; eight centiseconds per frame, looping.
        output.extend(b'\x21\xf9\x04\x08\x08\x00\x00\x00')
        output.extend(b'\x2c' + struct.pack('<HHHHB', 0, 0, WIDTH, HEIGHT, 0))
        output.append(5)
        compressed = lzw(draw_frame(index))
        for start in range(0, len(compressed), 255):
            block = compressed[start:start + 255]
            output.append(len(block))
            output.extend(block)
        output.append(0)
    output.append(0x3b)
    destination = (Path(__file__).resolve().parents[1] /
                   'frontend/assets/animations/task_complete_dance.gif')
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(output)
    print(f'Wrote {destination.name}: {FRAME_COUNT} frames, {len(output):,} bytes')


if __name__ == '__main__':
    main()
