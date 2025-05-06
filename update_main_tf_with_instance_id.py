import re

# Path to your main.tf file
main_tf_path = 'main.tf'

try:
    # Read the instance ID from the file
    with open('instance_id.txt', 'r') as file:
        instance_id = file.read().strip()

    if not instance_id:
        print("Error: The instance_id.txt file is empty or could not be read.")
        exit(1)

    # Read the current content of main.tf
    with open(main_tf_path, 'r') as file:
        content = file.read()

    # Regex pattern to find the line with aws:SourceInstance and its value
    pattern = r'"aws:SourceInstance"\s*=\s*".*?"'

    # Build the replacement string with the actual instance ID
    replacement = f'"aws:SourceInstance" = "{instance_id}"'

    # Perform the replacement
    updated_content, count = re.subn(pattern, replacement, content)

    if count > 0:
        # Write the updated content back to the file
        with open(main_tf_path, 'w') as file:
            file.write(updated_content)
        print(f"Updated main.tf with the instance ID: {instance_id}")
    else:
        print("Couldn't find any aws:SourceInstance entry to update in main.tf.")

except FileNotFoundError as e:
    print(f"Error: {e.filename} not found.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
