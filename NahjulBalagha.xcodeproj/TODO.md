# 📋 TODO: High Priority Tasks

## Status Legend
- ⏳ Not Started
- 🔄 In Progress
- ✅ Complete
- ⏸️ Paused

---

## High Priority Tasks

### 1. ✅ Remove or Implement SwiftData
**Status:** Complete  
**Priority:** High  
**Estimated Time:** 30 minutes

**Description:**
The `Item.swift` model is registered in the SwiftData container but never used. We need to either:
- Option A: Remove `Item.swift` and the unused ModelContainer setup
- Option B: Implement proper data persistence using SwiftData for all content

**Decision:** Remove unused SwiftData setup (can be added back later if needed)

**Files Modified:**
- [x] Delete `Item.swift` (to be deleted manually)
- [x] Updated `NahjulBalaghaApp.swift` to remove ModelContainer
- [x] ContentView.swift did not need modification (no modelContainer injection found)

---

### 2. ⏳ Consolidate Data Management
**Status:** Not Started  
**Priority:** High  
**Estimated Time:** 1-2 hours

**Description:**
Create a centralized `ContentRepository` to manage all content (sermons, letters, sayings) and eliminate data duplication across views.

**Tasks:**
- [ ] Create `ContentRepository.swift`
- [ ] Define unified search result type
- [ ] Move sample data to repository
- [ ] Update `SermonsView.swift` to use repository
- [ ] Update `LettersView.swift` to use repository
- [ ] Update `SayingsView.swift` to use repository
- [ ] Update `SearchView.swift` to use repository
- [ ] Update `ContentView.swift` to use repository
- [ ] Remove duplicate data definitions

---

### 3. ⏳ Persist Favorites with AppStorage
**Status:** Not Started  
**Priority:** High  
**Estimated Time:** 30 minutes

**Description:**
Implement persistent favorites storage so users don't lose their favorited sayings when the app restarts.

**Tasks:**
- [ ] Create `FavoritesManager.swift` utility
- [ ] Update `SayingsView.swift` to use persistent favorites
- [ ] Consider extending favorites to Letters and Sermons

---

### 4. ⏳ Secure API Key Storage
**Status:** Not Started  
**Priority:** High (Security)  
**Estimated Time:** 45 minutes

**Description:**
Replace UserDefaults storage of OpenRouter API key with Keychain for proper security.

**Tasks:**
- [ ] Create `KeychainHelper.swift`
- [ ] Implement save/load/delete methods
- [ ] Update `OpenRouterConfig` in `AIChatService.swift`
- [ ] Update `SettingsView.swift` to use Keychain
- [ ] Add migration code to move existing keys from UserDefaults to Keychain

---

## Notes

- Each task should be completed and committed separately
- Run the app after each task to ensure functionality
- Update this file with checkmarks as tasks are completed
- Add any issues or blockers discovered during implementation

---

## Next Steps After High Priority

Once high priority tasks are complete, we'll move to medium priority:
1. Refactor ContentView (extract HomeScreen, ChatPanel, SectionCard)
2. Standardize Detail Views
3. Improve Search functionality
4. Add Loading States

---

**Last Updated:** 2026-01-01
