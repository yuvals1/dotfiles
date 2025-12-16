# Colima DNS Resolution Fix

**Issue:** Docker builds fail with "dial tcp: lookup office-comp-srv on 127.0.0.53:53: server misbehaving"

**Root Cause:** Colima in "Broken" state → internal DNS resolver not working → `dnsHosts` from `colima.yaml` not applied

---

## Quick Fix (Temporary)

Add hostnames directly to Colima VM's `/etc/hosts`:

```bash
colima ssh -- sudo bash -c "echo '10.100.102.150  office-comp-srv' >> /etc/hosts && echo '51.16.176.240   treex-docker-registry' >> /etc/hosts"
```

**Verify it worked:**
```bash
colima ssh -- getent hosts office-comp-srv
colima ssh -- getent hosts treex-docker-registry
```

**Limitation:** Lost on `colima restart`

---

## Proper Fix (Permanent)

Recreate Colima to restore DNS resolver:

```bash
# 1. Stop and delete broken instance
colima stop default
colima delete default

# 2. Start fresh (config from ~/.colima/default/colima.yaml auto-applied)
colima start default --cpu 2 --memory 2 --disk 100 --arch x86_64 --vm-type=vz

# 3. Verify DNS resolution works
colima ssh -- getent hosts treex-docker-registry
# Should return: 51.16.176.240   treex-docker-registry
```

---

## How It Should Work

**Config in `~/.colima/default/colima.yaml`:**
```yaml
network:
  dnsHosts:
    office-comp-srv: 10.100.102.150
    treex-docker-registry: 51.16.176.240

docker:
  insecure-registries:
    - office-comp-srv:5000
    - treex-docker-registry:5000
```

**DNS Resolution Flow (when working):**
```
Docker build → systemd-resolved (127.0.0.53) → Lima DNS resolver → dnsHosts → IP address
```

**Why it broke:**
- Colima entered "Broken" state (check with `colima list`)
- Lima's internal DNS resolver stopped working
- `dnsHosts` entries never reached systemd-resolved

---

## Verification Commands

**Check Colima status:**
```bash
colima list
# Should show: Running, not Broken
```

**Test DNS resolution from host:**
```bash
colima ssh -- getent hosts office-comp-srv
colima ssh -- getent hosts treex-docker-registry
```

**Test Docker build can resolve:**
```bash
export DOCKER_REGISTRY=treex-docker-registry:5000
./docker/build.sh ubuntu-devtools
# Should succeed without DNS errors
```

---

## History

**2025-10-19:** Added `dnsHosts` to colima.yaml with provision script fallback
**2025-11-10:** Removed provision script (relied only on dnsHosts)
**2025-11-12:** Discovered Colima in "Broken" state, applied manual `/etc/hosts` fix

**Lesson:** If `dnsHosts` stops working, check `colima list` for "Broken" status first.

---

## Related Files

- `~/.colima/default/colima.yaml` (symlink to `~/dotfiles/.colima/default/colima.yaml`)
- `~/.colima/_lima/colima/lima.yaml` (generated Lima config with hostResolver)
- `/etc/hosts` inside Colima VM (temporary manual edits)

---

## Future Prevention

After editing `colima.yaml`, always restart:
```bash
colima restart default
```

If DNS still doesn't work after restart:
```bash
# Nuclear option - recreate VM
colima delete default && colima start default
```
