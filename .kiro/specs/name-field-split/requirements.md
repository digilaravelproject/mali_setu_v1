# Requirements Document

## Introduction

This feature splits the full name field into three separate UI components (Title, First Name, Last Name) while maintaining backward compatibility with the API that expects a single combined name string. This improves data collection granularity and user experience across all forms in the application.

## Glossary

- **Name_Field_Component**: The UI component that displays and captures name information
- **Title_Dropdown**: A dropdown selector for honorific titles (Mr., Mrs., Ms., Dr., Prof.)
- **First_Name_Field**: A text input field for capturing the user's first name and middle names
- **Last_Name_Field**: A text input field for capturing the user's last name
- **Name_Combiner**: The component that concatenates Title, First Name, and Last Name into a single string
- **Name_Parser**: The component that splits a combined name string into Title, First Name, and Last Name
- **API_Payload**: The JSON data structure sent to or received from the API
- **Registration_Form**: The user registration form
- **Profile_Update_Form**: The form for updating user profile information
- **Matrimony_Registration_Form**: The form for matrimony service registration
- **Target_Forms**: All forms in the application that currently use a full_name field

## Requirements

### Requirement 1: Display Separate Name Input Fields

**User Story:** As a user, I want to enter my title, first name, and last name in separate fields, so that I can provide structured name information.

#### Acceptance Criteria

1. THE Name_Field_Component SHALL display a Title_Dropdown with options "Mr.", "Mrs.", "Ms.", "Dr.", "Prof."
2. THE Name_Field_Component SHALL display a First_Name_Field for text input
3. THE Name_Field_Component SHALL display a Last_Name_Field for text input
4. THE Registration_Form SHALL use the Name_Field_Component
5. THE Profile_Update_Form SHALL use the Name_Field_Component
6. THE Matrimony_Registration_Form SHALL use the Name_Field_Component
7. FOR ALL Target_Forms, THE application SHALL replace full_name field with Name_Field_Component

### Requirement 2: Combine Name Fields for API Submission

**User Story:** As a developer, I want the three name fields combined into a single name key, so that the API contract remains unchanged.

#### Acceptance Criteria

1. WHEN a form is submitted, THE Name_Combiner SHALL concatenate Title, First_Name, and Last_Name with single spaces
2. THE Name_Combiner SHALL format the combined name as "Title FirstName LastName"
3. THE Name_Combiner SHALL include the combined name in the API_Payload under the key "name"
4. WHEN Title is empty, THE Name_Combiner SHALL format the combined name as "FirstName LastName"
5. THE Name_Combiner SHALL trim leading and trailing whitespace from the combined name
6. THE Name_Combiner SHALL replace multiple consecutive spaces with a single space

### Requirement 3: Parse API Response into Separate Fields

**User Story:** As a user, I want my previously saved name to appear in the correct fields, so that I can view and edit my name information.

#### Acceptance Criteria

1. WHEN the API_Payload contains a name value, THE Name_Parser SHALL extract the Title if present
2. THE Name_Parser SHALL recognize "Mr.", "Mrs.", "Ms.", "Dr.", "Prof." as valid titles
3. WHEN a valid title is found at the start of the name, THE Name_Parser SHALL populate the Title_Dropdown with that title
4. THE Name_Parser SHALL extract the last word as the Last Name
5. THE Name_Parser SHALL extract all words between the Title and Last Name as the First Name
6. WHEN no title is present, THE Name_Parser SHALL leave the Title_Dropdown empty
7. WHEN the name contains only one word, THE Name_Parser SHALL populate the First_Name_Field with that word and leave Last_Name_Field empty

### Requirement 4: Handle Edge Cases in Name Processing

**User Story:** As a user with a non-standard name format, I want the system to handle my name correctly, so that my information is captured accurately.

#### Acceptance Criteria

1. WHEN First_Name_Field contains multiple words, THE Name_Combiner SHALL include all words in the combined name
2. WHEN Last_Name_Field is empty, THE Name_Combiner SHALL include only Title and First_Name in the combined name
3. WHEN all fields are empty, THE Name_Combiner SHALL produce an empty string
4. THE Name_Parser SHALL trim whitespace from each extracted component before populating fields
5. WHEN the name contains extra spaces between words, THE Name_Parser SHALL normalize them to single spaces
6. THE Name_Parser SHALL handle names with periods after titles (e.g., "Mr." vs "Mr")

### Requirement 5: Maintain Data Integrity

**User Story:** As a developer, I want round-trip conversion to preserve name information, so that data is not lost during processing.

#### Acceptance Criteria

1. FOR ALL valid name combinations entered in the UI, combining then parsing SHALL produce equivalent field values
2. WHEN a name is parsed and then combined, THE resulting string SHALL match the original name after normalization
3. THE Name_Field_Component SHALL validate that First_Name_Field is not empty before allowing form submission
4. WHEN First_Name_Field is empty, THE Name_Field_Component SHALL display a validation error message

