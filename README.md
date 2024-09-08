# dev_shell

[toc]

## Redirections

Directory: [`redirections`](./redirections)

### Simple redirections without formatting

Execute:

```bash
./redirections/redirection.exec.01.simple.sh
```

Terminal output:

```text/plain
Before redirection 1
Before redirection 2
End of redirection 1
End of redirection 2
```

File output:

```text/plain
STDOUT message
STDERR message
```

### Basic text formatting with `awk` command

Execute:

```bash
./redirections/redirection.exec.02.text_awk.sh
```

Terminal output:

```text/plain
Before redirection 1
Before redirection 2
End of redirection 1
End of redirection 2
```

File output:

```text/plain
the_logger 2024-07-05T22:22:34 STDOUT message
the_logger 2024-07-05T22:22:37 STDERR message
```

### Improved JSON formatting with `jq` command

Execute:

```bash
./redirections/redirection.exec.03.json_jq.sh
```

Terminal output:

```text/plain
Before redirection 1
Before redirection 2
End of redirection 1
End of redirection 2
```

File output:

```json
{"logger_id":"the_logger","timestamp":"2024-07-05T22:23:22","message":"STDOUT message"}
{"logger_id":"the_logger","timestamp":"2024-07-05T22:23:25","message":"STDERR message"}
```
