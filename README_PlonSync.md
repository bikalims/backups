# Plone Instance Sync Script (for ext4-based servers)

This script provides a safe way to **replicate Plone instance data** (`Data.fs`, `blobstorage`, etc.) to a remote server using `rsync`, with support for **supervisor-controlled services** and an optional **dry-run** mode.

---

## 🗂️ Features

- Stops the instance via `supervisorctl` before syncing
- Uses `rsync` with compression and deletion for efficiency
- Restarts the instance after syncing
- Supports a `--dry-run` mode to preview the operation without making changes

---

## ⚙️ Requirements

- Plone instance managed by **Supervisor**
- `rsync` and `ssh` available on both servers
- Remote user must have write access to the destination path
- Script should be run on the **source server**

---

## 📥 Installation

Save the script as `sync_plone_instance.sh`:

```bash
chmod +x sync_plone_instance.sh
```

---

## 🧪 Usage

```bash
./sync_plone_instance.sh [--dry-run] /local/plone-instance user@remote:/remote/plone-instance
```

### ✅ Example (real sync)

```bash
./sync_plone_instance.sh /opt/plone/instance1 senaite@37.59.77.218:/opt/plone/instance1
```

### 🧪 Example (dry run)

```bash
./sync_plone_instance.sh --dry-run /opt/plone/instance1 senaite@37.59.77.218:/opt/plone/instance1
```

---

## 🕒 Cron Job Example

To schedule a sync at midnight every day:

```bash
0 0 * * * /opt/plone/scripts/sync_plone_instance.sh /opt/plone/instance1 senaite@37.59.77.218:/opt/plone/instance1 >> /var/log/sync_instance1.log 2>&1
```

For a dry run test:

```bash
0 23 * * * /opt/plone/scripts/sync_plone_instance.sh --dry-run /opt/plone/instance1 senaite@37.59.77.218:/opt/plone/instance1
```

---

## ⚠️ Notes

- This script is intended for **ext4-based systems** where no snapshotting (like LVM/ZFS) is available.
- For ZFS-based servers, prefer using ZFS snapshots with rsync to avoid stopping services.