Absolutely! Here's a **professional and practical README** that documents your `flatcar.yml` setup, explains the configurations, and provides the `docker run` command for transpiling it to an Ignition file.

---

# 📝 Flatcar Provisioning with Ignition (Butane) Config

This repository contains a **Butane configuration file** (`flatcar.yml`) designed to provision **Flatcar Linux** nodes with the following capabilities:

---

## 📦 What `flatcar.yml` Does

### ✅ 1. User Configuration

* **Creates the `core` user** with a pre-defined password hash for login.

### ✅ 2. Network Configuration

* Configures **DHCP** on multiple interfaces (`enp2s0` to `enp6s0`) by creating `.network` files under `/etc/systemd/network/`.
* Ensures `systemd-networkd` is **enabled** and starts on boot.

### ✅ 3. Flatcar Update and Reboot Policy

* Enables **automatic updates** via `update-engine.service`.
* Enables **automatic reboots** after updates with `locksmithd.service`.
* Sets the `REBOOT_STRATEGY=best-effort` policy to reboot when no locks are held.

---

## 🛠️ Generate Ignition Config (`.ign`) from `flatcar.yml`

You can generate the Ignition configuration without installing Butane locally by using a **Docker container**.

### 🚀 Docker Command

```bash
docker run --rm -i quay.io/coreos/butane:release \
  --pretty --strict < flatcar.yml > flatcar.ign
```

This command:

* Pulls the latest **Butane container**.
* Transpiles the **Butane YAML** (`flatcar.yml`) into an **Ignition JSON** (`flatcar.ign`).

---

## 🏗️ Example Usage

Once you have `flatcar.ign`, you can provision a Flatcar system with:

```bash
sudo flatcar-install -d /dev/sdX -i file:///path/to/flatcar.ign
```

Replace `/dev/sdX` with your actual target disk.

