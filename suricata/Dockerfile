# Use the official Suricata image as a base
FROM jasonish/suricata:latest

# Copy custom rules and configurations
COPY custom.rules /var/lib/suricata/rules/custom.rules
COPY suricata.yaml /etc/suricata/suricata.yaml
# (If needed, add any additional custom files or scripts)

# If you have any other setup or environment variables, you can include them here
# ENV MY_VARIABLE=value

# If you had a custom entry point or command, you'd specify them here. Otherwise, it'll inherit from the base image.
# ENTRYPOINT ["/path/to/entrypoint.sh"]
