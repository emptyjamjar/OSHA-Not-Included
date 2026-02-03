
## Core Functionality
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
Does the script do what it claims to do in normal use?

**Questions to ask:**
- Did I write a test for each public method?
- Do the tests confirm the expected output or state change?
- Does the “happy path” work?

**Examples:**
- Tested `add_item()` increases inventory size
- Tested `take_damage()` reduces health correctly
- Tested `is_empty()` returns true when expected
</details>

**Comments:**


## Edge Cases
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
Does the script behave correctly in unusual or boundary situations?

**Questions to ask:**
- Did I test empty, zero, min/max values?
- Did I test calling this method when the state is unusual?
- Did I test values right at the limits?

**Examples:**
- Tested adding zero items
- Tested removing an item from an empty inventory
- Tested cooldown at exactly 0 seconds
</details>

**Comments:**


## Failure Handling
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
What happens when something goes wrong or is used incorrectly?

**Questions to ask:**
- What happens if this method is used incorrectly?
- Does it fail safely instead of crashing?
- Is the failure behavior intentional and clear, or just undefined (we don't support this vs. we didn't think about this)?

**Examples:**
- Tested invalid item ID
- Tested damage applied to already-dead entity
- Tested missing data handled gracefully
</details>

**Comments:**


## State & Side Effects
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
Does this script only change what it’s supposed to change?

**Questions to ask:**
- Does the script start in a clean, expected state?
- After calling a method, is the internal state correct?
- Did anything else change that wasn't intended (It's not supposed to do that)?

**Examples:**
- Verified state resets correctly on initialization
- Verified calling a method twice doesn’t corrupt state
- Verified unrelated variables remain unchanged
</details>

**Comments:**


## Interactions With Other Scripts (Dependencies)
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
How does this script behave when other scripts use it?

**Questions to ask:**
- Does this script depend on another system?
- Did I test how they interact?
- Would a breaking change in a dependency be caught?

**Examples:**
- Tested inventory logic without UI
- Tested save system reading inventory data
- Mocked dependent script to isolate behavior
</details>

**Comments:**


## Known Issues (Bugs We Don't Want Back)
- [ ] Not Applicable ✖
- [ ] Completed ✔

<details>
<summary>Guidance (Click to Expand)</summary>

**What this means:**  
Has this broken before, and did we prevent it from breaking again?

**Questions to ask:**
- Is this fixing a known bug?
- Should there be a test to prevent it from coming back?

**Examples:**
- Added test for item duplication bug
- Added test for save/load data loss issue
</details>

**Comments:**

