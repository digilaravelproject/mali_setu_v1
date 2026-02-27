# Implementation Plan: Name Field Split Feature

## Overview

This implementation plan breaks down the name field split feature into incremental coding tasks. The approach follows a bottom-up strategy: first building the core utilities and models, then the reusable widget component, then integrating into existing forms, and finally adding comprehensive tests. Each task builds on previous work to ensure no orphaned code.

## Tasks

- [x] 1. Create core data model and utility classes
  - [x] 1.1 Create NameComponents model class
    - Create `lib/models/name_components.dart`
    - Implement NameComponents class with title, firstName, lastName fields
    - Add isEmpty getter, equality operator, and hashCode
    - _Requirements: 3.1, 3.4, 3.5_
  
  - [x] 1.2 Implement NameCombiner utility class
    - Create `lib/utils/name_combiner.dart`
    - Implement static combine() method that concatenates title, firstName, lastName
    - Handle empty fields, trim whitespace, normalize multiple spaces to single space
    - _Requirements: 2.1, 2.2, 2.4, 2.5, 2.6_
  
  - [ ]* 1.3 Write property test for NameCombiner
    - **Property 1: Name combiner concatenates with single spaces**
    - **Property 2: Name combiner normalizes whitespace**
    - **Validates: Requirements 2.1, 2.5, 2.6**
  
  - [x] 1.4 Implement NameParser utility class
    - Create `lib/utils/name_parser.dart`
    - Define validTitles constant list
    - Implement static parse() method that extracts title, firstName, lastName from combined string
    - Handle title variations (with/without period), single-word names, multiple middle names
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 4.4, 4.5, 4.6_
  
  - [ ]* 1.5 Write property tests for NameParser
    - **Property 3: Name parser extracts title when present**
    - **Property 4: Name parser extracts last word as last name**
    - **Property 5: Name parser extracts middle words as first name**
    - **Property 6: Name parser normalizes whitespace**
    - **Property 7: Name parser handles title variations**
    - **Validates: Requirements 3.1, 3.4, 3.5, 4.4, 4.5, 4.6**
  
  - [ ]* 1.6 Write unit tests for edge cases
    - Test NameCombiner with empty fields, single words, multiple spaces
    - Test NameParser with single-word names, no title, multiple middle names
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 2. Add localization strings
  - [x] 2.1 Add English localization keys
    - Update `lib/core/localization/en_US.dart`
    - Add keys: 'title', 'first_name', 'last_name', 'first_name_required'
    - Add title options: 'mr', 'mrs', 'ms', 'dr', 'prof'
    - _Requirements: 1.1_
  
  - [x] 2.2 Add Marathi localization keys
    - Update `lib/core/localization/mr_IN.dart`
    - Add translated versions of all keys from 2.1
    - _Requirements: 1.1_

- [x] 3. Create reusable NameFieldComponent widget
  - [x] 3.1 Implement NameFieldComponent stateful widget
    - Create `lib/widgets/name_field_component.dart`
    - Define constructor with initialName, isRequired, onChanged parameters
    - Create NameFieldComponentState with titleCtrl, firstNameCtrl, lastNameCtrl controllers
    - Implement initState() to parse initialName if provided
    - Implement dispose() to clean up controllers
    - _Requirements: 1.2, 1.3, 3.1, 3.3, 3.6_
  
  - [x] 3.2 Build widget UI with three input fields
    - Implement build() method with Column layout
    - Add Title dropdown using AppInputTextField with isDropdown=true
    - Add First Name field using AppInputTextField with validation
    - Add Last Name field using AppInputTextField
    - Use localized labels for all fields
    - _Requirements: 1.1, 1.2, 1.3_
  
  - [x] 3.3 Implement getCombinedName() and validate() methods
    - Add getCombinedName() method that calls NameCombiner.combine()
    - Add validate() method that checks first name is not empty
    - Implement onChanged callback to notify parent of changes
    - _Requirements: 2.1, 2.3, 5.3_
  
  - [ ]* 3.4 Write widget tests for NameFieldComponent
    - Test component renders all three fields
    - Test initialName parsing populates fields correctly
    - Test getCombinedName() returns correct format
    - Test validation with empty first name
    - _Requirements: 1.1, 1.2, 1.3, 3.1, 5.3_

- [ ] 4. Checkpoint - Verify core components work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Integrate NameFieldComponent into Registration form
  - [x] 5.1 Update register_page.dart to use NameFieldComponent
    - Locate existing full_name AppInputTextField in registration form
    - Replace with NameFieldComponent using GlobalKey<NameFieldComponentState>
    - Update form submission logic to call nameFieldKey.currentState?.getCombinedName()
    - Ensure combined name is included in registration API payload under "name" key
    - _Requirements: 1.4, 2.3_
  
  - [ ]* 5.2 Write integration test for registration form
    - Test form submission includes combined name in correct format
    - Test validation prevents submission with empty first name
    - _Requirements: 1.4, 2.3, 5.3_

- [x] 6. Integrate NameFieldComponent into Profile Update form
  - [x] 6.1 Update update_profile_page.dart to use NameFieldComponent
    - Locate existing fullNameCtrl TextField in profile update form
    - Replace with NameFieldComponent passing initialName: user.name
    - Update updateProfile() method to use combined name from component
    - Ensure combined name is included in update API payload under "name" key
    - _Requirements: 1.5, 2.3, 3.1_
  
  - [ ]* 6.2 Write integration test for profile update form
    - Test existing name is parsed and displayed in separate fields
    - Test form submission includes updated combined name
    - _Requirements: 1.5, 2.3, 3.1, 5.1_

- [x] 7. Integrate NameFieldComponent into Matrimony Registration form
  - [x] 7.1 Update reg_matrimony_page.dart to use NameFieldComponent
    - Locate existing nameCtrl TextField in matrimony registration form
    - Replace with NameFieldComponent using GlobalKey<NameFieldComponentState>
    - Update payload construction to use combined name from component
    - Ensure combined name is included in matrimony API payload under "name" key
    - _Requirements: 1.6, 2.3_
  
  - [ ]* 7.2 Write integration test for matrimony form
    - Test form submission includes combined name in correct format
    - Test validation prevents submission with empty first name
    - _Requirements: 1.6, 2.3, 5.3_

- [ ] 8. Write round-trip property tests
  - [ ]* 8.1 Write property test for combine-then-parse round trip
    - **Property 8: Round-trip combine then parse preserves components**
    - Generate random title, firstName, lastName combinations
    - Verify combining then parsing produces equivalent normalized components
    - **Validates: Requirements 5.1**
  
  - [ ]* 8.2 Write property test for parse-then-combine round trip
    - **Property 9: Round-trip parse then combine preserves name**
    - Generate random name strings with various formats
    - Verify parsing then combining produces equivalent normalized string
    - **Validates: Requirements 5.2**

- [ ] 9. Final checkpoint - Verify all forms and tests
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties across all inputs
- Unit tests validate specific examples and edge cases
- Widget tests verify UI behavior and user interactions
- Integration tests ensure forms work correctly with the new component
- All three forms (Registration, Profile Update, Matrimony) must be updated to maintain consistency
