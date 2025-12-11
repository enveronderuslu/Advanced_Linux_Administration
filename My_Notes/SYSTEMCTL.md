## systemctl – Instruction Notes (Red Hat–based Systems)

### Core Concepts
**Unit**: A configuration object managed by systemd (service, socket, mount, timer, target). Stored under `/usr/lib/systemd/system/` or `/etc/systemd/system/`.

**Target**: A unit type grouping other units to define a system state (e.g., `multi-user.target`, `graphical.target`, `rescue.target`). Replaces legacy runlevels.

---

### Commands

**systemctl start \<unit>**
Starts a unit immediately.  
**Best practice**: Start only validated, enabled services.  
**Use case**: Starting `httpd.service` after configuration.

**systemctl status \<unit>**
Shows active state, logs, metadata.  
**Best practice**: Always check status before troubleshooting.  
**Use case**: Verifying `sshd.service`.

**systemctl restart \<unit>**
Stops and starts the unit.  
**Best practice**: Use after config changes.  
**Use case**: Reloading web server settings.

**systemctl stop \<unit>**
Stops a running service.  
**Best practice**: Confirm no critical dependencies rely on it.  
**Use case**: Stopping `firewalld.service` safely.

**systemctl enable \<unit>**
Activates automatic start at boot.  
**Best practice**: Enable only essential long-running services.  
**Use case**: Enabling `chronyd.service`.

**systemctl disable \<unit>**
Prevents boot-time start.  
**Best practice**: Disable unused or risky services.  
**Use case**: Disabling an unused database service.

**systemctl list-units**
Shows loaded and active units.  
**Best practice**: Filter by type for clarity.  
**Use case**: Auditing running services.

**systemctl set-default \<target>**
Sets system boot target.  
**Best practice**: Use `multi-user.target` for servers.  
**Use case**: Switching from graphical to text-only mode.

**systemctl get-default**
Displays current default target.  
**Best practice**: Verify before rebooting.  
**Use case**: Checking that CLI mode is active.

**systemctl cat \<unit>**
Shows full unit definition.  
**Best practice**: Review before editing.  
**Use case**: Inspecting `sshd.service`.

**systemctl show \<unit>**
Displays all runtime properties.  
**Best practice**: Use for deep diagnostics.  
**Use case**: Verifying dependencies.

**systemctl edit \<unit>**
Creates drop-in overrides under `/etc/systemd/system/<unit>.d/`.  
**Best practice**: Never modify vendor files.  
**Use case**: Adding environment variables to a service.

**systemctl daemon-reload**
Reloads unit files after edits.  
**Best practice**: Run after any unit modification.  
**Use case**: Applying new service definitions.

**systemctl isolate \<target>**
Switches to another system state.  
**Best practice**: Use cautiously; may stop many services.  
**Use case**: Entering `rescue.target`.

**systemctl list-dependencies \<unit>**
Shows dependency tree.  
**Best practice**: Review before disabling or isolating.  
**Use case**: Understanding `graphical.target`.

**systemctl isolate emergency.target**
Enters minimal environment.  
**Best practice**: Use only for critical recovery.  
**Use case**: Fixing filesystem corruption.

**systemctl list-units -t target**
Lists all targets.  
**Best practice**: Identify available system states.  
**Use case**: Checking custom targets.

**systemctl edit sound.target**
Creates a drop-in for `sound.target`.  
**Best practice**: Adjust grouped services at the target level.  
**Use case**: Overriding audio subsystem behavior.

**systemctl start name.target**
Starts all units in the target.  
**Best practice**: Use for structured subsystem startup.  
**Use case**: Starting an application stack.

**systemctl isolate name.target**
Switches to the custom target.  
**Best practice**: Ensure all required core units exist.  
**Use case**: Application-specific environments.

**systemctl list-dependencies name.target**
Shows dependencies of a custom target.  
**Best practice**: Validate tree before production use.  
**Use case**: Checking completeness of grouped services.

**systemctl set-default name.target**
Sets a custom target as the boot default.  
**Best practice**: Apply only if thoroughly tested.  
**Use case**: Booting directly into an application environment.

**systemctl set-default emergency.target**
systemctl start default.target
Sets emergency mode as default, then returns to normal.  
**Best practice**: Avoid except in controlled recovery tests.  
**Use case**: Disaster-recovery validation.

**systemctl set-default graphical.target**
systemctl start default.target
Sets graphical mode as default and switches to it.  
**Best practice**: Use on workstations, not servers.  
**Use case**: Restoring GUI functionality.
