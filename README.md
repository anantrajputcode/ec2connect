# ec2connect

A small bash script to SSH into an EC2 instance by key file name and host.
Runs a quick non-interactive connectivity check first, then opens a real
interactive SSH session if that check succeeds.

## How it works

1. Validates that a key file name and host were both provided
2. Checks the key file exists at `~/.ssh/aws-keys/<key-file-name>`
3. Locks down the key's permissions (`chmod 400`)
4. Runs a silent, non-interactive test connection (`ssh ... "exit"`) to
   confirm the key/host/security group are all working
5. If the test passes, opens a real interactive SSH session
6. Prints a message once the session ends

## Requirements

- An EC2 key file, e.g. a `.pem` file
- macOS or Linux (bash is built in on both). Not compatible with Windows
  `cmd.exe` / PowerShell as-is — use WSL or Git Bash on Windows instead.

## Setup

### 1. Place your key file

Keys go in `~/.ssh/aws-keys/`, **not** `~/Documents/` or `~/Downloads/`,
since those folders are often synced to iCloud/OneDrive and could leak
your private key off your machine.

```bash
mkdir -p ~/.ssh/aws-keys
mv /path/to/downloaded/your-key.pem ~/.ssh/aws-keys/
chmod 700 ~/.ssh/aws-keys
chmod 400 ~/.ssh/aws-keys/your-key.pem
```

The script also runs `chmod 400` on the key automatically every time it's
used, so permissions stay correct even if they ever get reset.

### 2. Install the script as a command

```bash
mkdir -p ~/bin
cp ec2connect.sh ~/bin/ec2connect
chmod +x ~/bin/ec2connect
```

Add `~/bin` to your `PATH`:

- **macOS (zsh):**
  ```bash
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
  ```
- **Linux (bash):**
  ```bash
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

Verify:

```bash
which ec2connect
```

## Usage

```bash
ec2connect <key-file-name> <host>
```

Example:

```bash
ec2connect your-key.pem 1.2.3.4
```

## Notes

- **User is hardcoded as `ubuntu`**, matching Ubuntu-based EC2 AMIs. If
  you're using Amazon Linux, change `ubuntu@` to `ec2-user@` in the
  script.
- **`StrictHostKeyChecking=no`** skips the first-connection host key
  prompt *and* silently accepts host key changes later (e.g. a recycled
  EC2 IP now pointing at a different instance). Convenient for EC2, but
  offers no protection if a host key genuinely changes — see below for
  a stronger option.
- Never commit your `.pem` file to any git repo, even a private one.

## Security: a stronger alternative

Replace `StrictHostKeyChecking=no` with `StrictHostKeyChecking=accept-new`
in both `ssh` calls. This still skips prompts for hosts you've never seen
before, but will warn you (instead of silently proceeding) if a
*previously known* host's key changes — which can indicate a real
security issue, not just IP reuse on a fresh instance.

## Troubleshooting

| Error | Likely cause |
|---|---|
| `No key found at: ...` | Key isn't in `~/.ssh/aws-keys/`, or the filename doesn't match exactly |
| `Connection failed...` | Wrong host IP, instance is stopped, or the EC2 security group doesn't allow inbound SSH (port 22) from your IP |
| `Permissions ... are too open` | Shouldn't happen (script runs `chmod 400` automatically), but if it does, run `chmod 400 ~/.ssh/aws-keys/your-key.pem` manually |

## License

MIT

