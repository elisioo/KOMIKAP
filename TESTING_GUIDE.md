# Testing Guide - Real API Implementation

## 🚀 Quick Start (2 minutes)

```bash
# 1. Run the app
flutter run

# 2. Wait for app to load

# 3. You should see:
#    - Popular manga on Home tab
#    - Search functionality on Browse tab
#    - Real manga chapters when you tap a manga
#    - Real images when you open a chapter

# Done! ✅
```

---

## 🧪 Test Scenarios

### Test 1: View Popular Manga (Home Tab)
**Steps:**
1. Run the app
2. App opens on Home tab
3. Scroll down to see sections

**Expected Results:**
- ✅ "Popular Manga" section shows 6 manga
- ✅ Each manga has a cover image
- ✅ Manga titles are visible
- ✅ Status (Ongoing/Completed) is shown
- ✅ No errors in console

**What You'll See:**
```
┌─────────────────────────────────┐
│  KOMIKAP                        │
│  Welcome to KOMIKAP             │
│  Explore thousands of manga     │
└─────────────────────────────────┘
│ Popular Manga                   │
├─────────────────────────────────┤
│ [Cover] [Cover] [Cover]         │
│ Manga1  Manga2  Manga3          │
│ Ongoing Ongoing Completed       │
│ [Cover] [Cover] [Cover]         │
│ Manga4  Manga5  Manga6          │
│ Ongoing Ongoing Ongoing         │
├─────────────────────────────────┤
│ Recently Updated                │
├─────────────────────────────────┤
│ [Cover] Manga7                  │
│         Ongoing                 │
│ [Cover] Manga8                  │
│         Completed               │
└─────────────────────────────────┘
```

---

### Test 2: Search for Manga (Browse Tab)
**Steps:**
1. Go to Browse tab
2. See popular manga displayed
3. Type "One Piece" in search box
4. See search results

**Expected Results:**
- ✅ Popular manga shows in grid initially
- ✅ Search box is active
- ✅ Results update as you type
- ✅ Grid shows search results
- ✅ Manga covers are visible
- ✅ No errors in console

**What You'll See:**
```
Before Search:
┌─────────────────────────────────┐
│  Search                         │
│  [Search box]                   │
├─────────────────────────────────┤
│ Popular Manga                   │
├─────────────────────────────────┤
│ [Cover] [Cover]                 │
│ Manga1  Manga2                  │
│ [Cover] [Cover]                 │
│ Manga3  Manga4                  │
└─────────────────────────────────┘

After Typing "One Piece":
┌─────────────────────────────────┐
│  Search                         │
│  [One Piece        X]           │
├─────────────────────────────────┤
│ Search Results                  │
├─────────────────────────────────┤
│ [One Piece] [One Piece]         │
│ Ongoing     Completed           │
│ [One Piece] [One Piece]         │
│ Ongoing     Ongoing             │
└─────────────────────────────────┘
```

---

### Test 3: Open Manga Detail (Tap Manga)
**Steps:**
1. Tap any manga from Home or Browse
2. Detail screen opens
3. Scroll to see chapters

**Expected Results:**
- ✅ Detail screen opens
- ✅ Manga cover is displayed
- ✅ Title and author shown
- ✅ Description visible
- ✅ Real chapters load from API
- ✅ Chapter list shows with dates
- ✅ No errors in console

**What You'll See:**
```
┌─────────────────────────────────┐
│ ← One Piece                     │
├─────────────────────────────────┤
│ [Large Cover Image]             │
│ One Piece                       │
│ by Eiichiro Oda                 │
│ Ongoing | +14                   │
├─────────────────────────────────┤
│ Description                     │
│ Lorem ipsum dolor sit amet...   │
│ [More]                          │
├─────────────────────────────────┤
│ Chapters                        │
├─────────────────────────────────┤
│ Chapter 1100 - Title            │
│ 2025-01-15 | 45 pages           │
│ Chapter 1099 - Title            │
│ 2025-01-10 | 42 pages           │
│ Chapter 1098 - Title            │
│ 2025-01-05 | 48 pages           │
└─────────────────────────────────┘
```

---

### Test 4: Read Manga (Tap Chapter)
**Steps:**
1. Open a manga detail screen
2. Tap any chapter
3. Reader opens
4. Scroll through pages

**Expected Results:**
- ✅ Reader screen opens
- ✅ First page loads
- ✅ Page count shows (e.g., "Page 1/45")
- ✅ Images are visible
- ✅ Scrolling works smoothly
- ✅ No errors in console

**What You'll See:**
```
┌─────────────────────────────────┐
│ ← One Piece | Ch. 1100 - Pg 1/45│
├─────────────────────────────────┤
│                                 │
│      [Manga Page Image]         │
│      (Real image from MangaDex) │
│                                 │
│      Scroll down to next page    │
│                                 │
├─────────────────────────────────┤
│ [Bookmark] [Settings] [Chapters]│
└─────────────────────────────────┘
```

---

## ✅ Verification Checklist

### Home Screen
- [ ] App loads without crashing
- [ ] Popular Manga section shows 6 manga
- [ ] Recently Updated section shows 6 manga
- [ ] All manga have cover images
- [ ] Titles are visible
- [ ] Status is shown
- [ ] No loading errors
- [ ] Tapping manga opens detail screen

### Browse Screen
- [ ] Search box is visible
- [ ] Popular manga shows initially
- [ ] Typing updates search results
- [ ] Grid layout shows 2 columns
- [ ] Manga covers are visible
- [ ] Titles are visible
- [ ] No loading errors
- [ ] Tapping manga opens detail screen

### Detail Screen
- [ ] Manga cover displays
- [ ] Title and author shown
- [ ] Description visible
- [ ] Chapters load from API
- [ ] Chapter list shows real data
- [ ] Dates are visible
- [ ] Page counts shown
- [ ] Tapping chapter opens reader

### Reader Screen
- [ ] Chapter images load
- [ ] Page count displays
- [ ] Images are visible
- [ ] Scrolling works
- [ ] No loading errors
- [ ] Controls work (bookmark, settings, chapters)

---

## 🐛 Common Issues & Solutions

### Issue: Manga not showing
**Cause:** API not responding or internet connection issue
**Solution:**
1. Check internet connection
2. Restart the app
3. Check MangaDex API status
4. Try again in a few moments

### Issue: Images not loading
**Cause:** MangaDex server issue or image URL invalid
**Solution:**
1. Check internet connection
2. Try different manga
3. Restart the app
4. Check MangaDex status

### Issue: Search not working
**Cause:** API error or invalid search query
**Solution:**
1. Try different manga name
2. Check spelling
3. Restart the app
4. Check internet connection

### Issue: App crashes on startup
**Cause:** ProviderScope not wrapping app
**Solution:**
1. Check main.dart has ProviderScope
2. Rebuild the app
3. Run `flutter clean` then `flutter run`

### Issue: Slow loading
**Cause:** First-time load or slow internet
**Solution:**
1. Wait for initial load
2. Images cache after first load
3. Check internet speed
4. Try with better connection

---

## 📊 Performance Expectations

| Action | Expected Time |
|--------|---------------|
| App startup | < 2 seconds |
| Load popular manga | < 1 second |
| Search manga | < 1 second |
| Load detail screen | < 1 second |
| Load chapter images | < 2 seconds |
| Load cached images | < 100ms |

---

## 🎯 Test Data

### Popular Manga (Usually includes)
- One Piece
- Naruto
- Bleach
- My Hero Academia
- Jujutsu Kaisen
- Chainsaw Man

### Search Examples
- Try: "One Piece"
- Try: "Naruto"
- Try: "Demon Slayer"
- Try: "Attack on Titan"
- Try: "Death Note"

---

## 📱 Device Testing

### Recommended Devices
- Android 8.0+ (API 26+)
- iOS 11.0+
- Screen sizes: 5" to 7"

### Test Orientations
- Portrait (primary)
- Landscape (optional)

### Network Conditions
- WiFi (recommended for first test)
- 4G/5G (for performance test)
- Slow connection (for error handling test)

---

## 🔍 Debug Tips

### Check Console Logs
```bash
# Run with verbose logging
flutter run -v

# Look for:
# - API request logs
# - Image loading logs
# - Error messages
```

### Check Network Requests
```bash
# Use Chrome DevTools
# Or check MangaDex API docs
# https://api.mangadex.org/docs
```

### Test API Directly
```bash
# Test popular manga endpoint
curl "https://api.mangadex.org/manga?limit=6&order[followedCount]=desc&includes[]=cover_art"

# Test search endpoint
curl "https://api.mangadex.org/manga?title=One%20Piece&limit=20&includes[]=cover_art"
```

---

## ✨ Success Criteria

Your implementation is successful when:
- ✅ Home screen shows real manga
- ✅ Browse screen has working search
- ✅ Detail screen shows real chapters
- ✅ Reader screen shows real images
- ✅ No crashes or errors
- ✅ Smooth user experience
- ✅ Fast loading times
- ✅ Professional appearance

---

## 📝 Notes

- First load may take 1-2 seconds
- Images cache automatically
- Subsequent loads are faster
- Search works in real-time
- All data is from MangaDex API
- No mock data is used

---

**Status: READY FOR TESTING** ✅

Run `flutter run` and enjoy reading real manga!
