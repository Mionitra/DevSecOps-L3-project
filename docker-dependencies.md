services:

  bandit:
    build: ./bandit
    volumes:
      - ./:/app
    command: -r /app -f json -o /app/security-reports/bandit.json

  semgrep:
    build: ./semgrep
    volumes:
      - ./:/app
    command: scan --config auto --json --output /app/security-reports/semgrep.json /app

  gitleaks:
    build: ./gitleaks
    volumes:
      - ./:/app
    command: detect --source /app --report-format json --report-path /app/security-reports/gitleaks.json


  trivy:
    image: aquasec/trivy:latest
    volumes:
      - ./:/app
    command: fs /app -f json -o /app/security-reports/trivy.json

  dependency-check:
    image: owasp/dependency-check
    volumes:
      - ./:/src
      - ./security-reports:/report
    command: --scan /src --format JSON --out /report

  cosign:
    build: ./cosign
    volumes:
      - ./:/app
    entrypoint: ["cosign"]