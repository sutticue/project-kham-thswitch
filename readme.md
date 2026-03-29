# Project Kham (THswitch)

**Thai/English input switcher for macOS — built with Hammerspoon**

แก้ปัญหาพิมพ์ผิดภาษาด้วยการกด `Shift+Backspace` เพื่อแปลงคำล่าสุดและสลับภาษาให้อัตโนมัติ รองรับทั้งสองทิศทาง (EN→TH และ TH→EN)

---

## ทำไมถึงสร้าง

บน macOS มีสองปัญหาที่เจอบ่อยมากเวลาพิมพ์ภาษาไทย

อย่างแรกคือ CapsLock delay — macOS มี delay ในตัวทำให้กด CapsLock เพื่อสลับภาษาแล้วต้องรอสักครู่ ซึ่งรู้สึกติดขัดมากเวลาต้องสลับไปมาบ่อย ๆ

อย่างที่สองคือพิมพ์ยาวไปแล้วดันพิมพ์ผิดภาษา — บางทีพิมพ์ไปหลายคำแล้วถึงจะรู้ว่า layout ไม่ถูก แทนที่จะต้องลบแล้วพิมพ์ใหม่ทั้งหมด Project Kham ให้กด `Shift+Backspace` เพื่อแปลงทั้งประโยคพร้อมสลับ layout ให้เลยในทีเดียว

---

## Features

- `Shift+Backspace` — แปลงคำล่าสุดที่พิมพ์ผิดภาษา พร้อมสลับ layout ให้อัตโนมัติ
- `CapsLock` — สลับภาษาแบบ instant ไม่มี lag (แก้ปัญหา macOS CapsLock delay)
- รองรับทั้ง EN→TH และ TH→EN ในปุ่มเดียวกัน
- ซ่อน alert อัตโนมัติเมื่ออยู่ใน password field
- ไม่มี network call ไม่เก็บข้อมูล รัน local ทั้งหมด

---

## Requirements

- macOS (Apple Silicon หรือ Intel)
- [Hammerspoon](https://www.hammerspoon.org/) 

---

## Installation

**1. ติดตั้ง Hammerspoon**

ดาวน์โหลดจาก [hammerspoon.org](https://www.hammerspoon.org/) แล้วลาก `.app` เข้า Applications

**2. ให้ Accessibility permission**

เปิด Hammerspoon ครั้งแรก → System Settings → Privacy & Security → Accessibility → เปิด toggle ให้ Hammerspoon

**3. ปิด CapsLock delay**

System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys → ตั้ง `CapsLock Key = No Action`

**4. ติดตั้ง Momentum**

```bash
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/sutticue/project-kham-thswitch/main/init.lua
```

หรือ copy `init.lua` ไปวางที่ `~/.hammerspoon/init.lua` แล้ว Reload Config ใน Hammerspoon

---

## Usage

| Hotkey | การทำงาน |
|--------|----------|
| `Shift+Backspace` | แปลงคำล่าสุดที่พิมพ์ผิดภาษา + สลับ layout |
| `CapsLock` | สลับภาษา EN/TH แบบ instant |

### ตัวอย่าง

```
พิมพ์ใน EN layout:  l;ylfu8iy[
กด Shift+Backspace: สวัสดีครับ  ✓

พิมพ์ใน TH layout:  ้ำสสน
กด Shift+Backspace: hello  ✓
```

---

## Keyboard Layout

รองรับ Thai Kedmanee (มาตรฐาน) ↔ ABC (QWERTY)

หากใช้ layout อื่น แก้ได้ที่บรรทัดบนสุดของ `init.lua`

```lua
local LAYOUT_EN = "ABC"   -- เปลี่ยนตามเครื่องของคุณ
local LAYOUT_TH = "Thai"  -- เปลี่ยนตามเครื่องของคุณ
```

เช็กชื่อ layout ในเครื่องได้โดยเปิด Hammerspoon Console แล้วรัน

```lua
print(hs.keycodes.currentLayout())
```

---

## How it works

Momentum ใช้ `hs.eventtap` ของ Hammerspoon ดัก keystroke ทุกตัวที่พิมพ์ เก็บไว้ใน buffer พร้อมจำ layout ที่ใช้อยู่ตอนนั้น เมื่อกด `Shift+Backspace` มันจะลบคำใน buffer ออก แล้วแปลงผ่าน mapping table แล้วพิมพ์คำใหม่กลับเข้าไปพร้อมสลับ layout ให้ครับ

ไม่มี auto-detection ไม่มี false positive — ทำงานเฉพาะตอนที่คุณสั่งเท่านั้น

---

## License

MIT
