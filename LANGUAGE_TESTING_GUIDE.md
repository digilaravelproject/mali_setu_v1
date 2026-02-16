# Language System Testing Guide

## Quick Test Steps

### 1. Initial Test - Change to Marathi
1. Run the app
2. Navigate to Settings (bottom navigation)
3. Tap on "App Language" option
4. You should see 2 language options:
   - 🇬🇧 English (currently selected with checkmark)
   - 🇮🇳 Marathi (मराठी)
5. Tap on "Marathi" option
6. Loading dialog appears briefly
7. Success message: "भाषा यशस्वीरित्या बदलली" (Language changed successfully)
8. Returns to Settings screen
9. **Verify**: All text should now be in Marathi

### 2. Persistence Test - App Restart
1. With app in Marathi, close the app completely
   - On Android: Swipe away from recent apps
   - On iOS: Swipe up and close
2. Reopen the app
3. **Verify**: App should open in Marathi (not English)
4. Navigate to Settings
5. **Verify**: "App Language" and other text still in Marathi

### 3. Change Back to English
1. In Settings, tap "अॅप भाषा" (App Language in Marathi)
2. Tap on "English" option
3. Success message: "Language changed successfully"
4. **Verify**: All text changes back to English

### 4. Persistence Test - English
1. Close app completely
2. Reopen app
3. **Verify**: App opens in English

## What to Look For

### ✅ Success Indicators
- Language changes immediately (no app restart needed)
- Success message appears after selection
- All screens update to new language
- Language persists after app restart
- Selected language shows checkmark in language page
- Smooth transitions with loading indicator

### ❌ Potential Issues
- If language doesn't persist → Check SharedPreferences initialization
- If some text doesn't change → Missing translation keys
- If app crashes → Check console for errors
- If loading never ends → Check network/async issues

## Debug Logs to Monitor

Open your IDE console and look for these logs:

### On App Start
```
DEBUG_LANGUAGE: ========================================
DEBUG_LANGUAGE: Loading saved language...
DEBUG_LANGUAGE: Saved language code: mr
DEBUG_LANGUAGE: ✅ Loaded Marathi language
DEBUG_LANGUAGE: ========================================
```

### On Language Change
```
DEBUG_LANGUAGE: ========================================
DEBUG_LANGUAGE: Changing language to: mr
DEBUG_LANGUAGE: Setting locale to Marathi (mr_IN)
DEBUG_LANGUAGE: ✅ Locale updated in GetX
DEBUG_LANGUAGE: ✅ Language saved to SharedPreferences
DEBUG_LANGUAGE: Verification - Saved language: mr
DEBUG_LANGUAGE: ========================================
```

## Common Screens to Test

After changing language, verify these screens show translated text:

1. **Settings Screen**
   - "Profile & Settings" → "प्रोफाइल आणि सेटिंग्ज"
   - "App Language" → "अॅप भाषा"
   - "Logout" → "लॉगआउट"

2. **Language Selection Screen**
   - "Select Language" → "भाषा निवडा"
   - "Language changed successfully" → "भाषा यशस्वीरित्या बदलली"

3. **Other Screens** (if using .tr keys)
   - Home, Business, Matrimony, Volunteer tabs
   - Any screen using translation keys

## Expected Behavior

### First Time User
- App opens in English (default)
- No saved language in SharedPreferences
- User can select preferred language
- Selection is saved for future sessions

### Returning User
- App opens in previously selected language
- No need to select language again
- Can change language anytime from Settings

## Troubleshooting

### Issue: Language doesn't persist
**Solution**: Check if `SharedPrefs.init()` is called in `initApp()`

### Issue: Some text not translating
**Solution**: Check if text uses `.tr` extension (e.g., `'select_language'.tr`)

### Issue: App crashes on language change
**Solution**: Check console for errors, verify translation keys exist in both files

### Issue: Loading never completes
**Solution**: Check if `isLoading.value = false` is in finally block

## Manual Verification Checklist

- [ ] Language changes immediately on selection
- [ ] Success message appears in correct language
- [ ] All visible text updates to new language
- [ ] Language persists after app restart
- [ ] Can switch between English and Marathi multiple times
- [ ] No crashes or errors in console
- [ ] Loading indicator shows and hides properly
- [ ] Selected language shows checkmark
- [ ] Debug logs appear in console

## Performance Notes

- Language change should be instant (< 500ms)
- No noticeable lag or freezing
- Smooth animations and transitions
- SharedPreferences save is async but fast

## Next Steps After Testing

If all tests pass:
1. Add more translation keys as needed
2. Translate static text in other screens
3. Consider adding more languages in future
4. Update app store descriptions to mention language support

If tests fail:
1. Check console logs for errors
2. Verify SharedPreferences initialization
3. Ensure GetX is properly configured
4. Check translation key consistency
