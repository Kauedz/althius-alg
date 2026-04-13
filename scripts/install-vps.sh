#!/bin/bash
# ============================================
#  Althius ALG — Instalação automática VPS
#  Testado em: Ubuntu 22.04 / 24.04
# ============================================
set -euo pipefail

REPO_URL="https://github.com/Kauedz/althius-alg.git"
BRANCH="main"
INSTALL_DIR="/opt/althius"
ENV_FILE="$INSTALL_DIR/docker/.env"

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║        ALTHIUS ALG — Instalador      ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# --- 1. Instalar Docker se não tiver ---
if ! command -v docker &>/dev/null; then
  echo "[1/5] Instalando Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
else
  echo "[1/5] Docker já instalado."
fi

# --- 2. Instalar Docker Compose plugin ---
if ! docker compose version &>/dev/null; then
  echo "[2/5] Instalando Docker Compose..."
  apt-get update && apt-get install -y docker-compose-plugin
else
  echo "[2/5] Docker Compose já instalado."
fi

# --- 3. Clonar repositório ---
if [ -d "$INSTALL_DIR" ]; then
  echo "[3/5] Atualizando repositório..."
  cd "$INSTALL_DIR"
  git fetch origin "$BRANCH"
  git reset --hard "origin/$BRANCH"
else
  echo "[3/5] Clonando repositório..."
  git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# --- 4. Configurar .env ---
if [ ! -f "$ENV_FILE" ]; then
  echo "[4/5] Criando arquivo .env..."

  AUTH_SECRET=$(openssl rand -hex 32)
  PG_PASS=$(openssl rand -hex 16)

  read -rp "Seu domínio (ex: alg.althius.com): " DOMAIN
  read -rp "Chave OpenAI (ou deixe vazio): " OPENAI_KEY
  read -rp "Chave Anthropic (ou deixe vazio): " ANTHROPIC_KEY

  cat > "$ENV_FILE" <<EOF
ALTHIUS_DOMAIN=${DOMAIN}
ALTHIUS_PUBLIC_URL=https://${DOMAIN}
BETTER_AUTH_SECRET=${AUTH_SECRET}
POSTGRES_PASSWORD=${PG_PASS}
OPENAI_API_KEY=${OPENAI_KEY}
ANTHROPIC_API_KEY=${ANTHROPIC_KEY}
EOF

  echo "   .env criado com segredos gerados automaticamente."
else
  echo "[4/5] .env já existe, pulando."
fi

# --- 5. Subir containers ---
echo "[5/5] Construindo e subindo Althius ALG..."
cd "$INSTALL_DIR/docker"
docker compose -f docker-compose.prod.yml --env-file .env up -d --build

echo ""
echo "  ✅ Althius ALG rodando!"
echo ""
echo "  Acesse: https://$DOMAIN"
echo "  (Aponte o DNS do domínio para o IP desta VPS)"
echo ""
echo "  Comandos úteis:"
echo "    cd /opt/althius/docker"
echo "    docker compose -f docker-compose.prod.yml logs -f    # ver logs"
echo "    docker compose -f docker-compose.prod.yml restart     # reiniciar"
echo "    docker compose -f docker-compose.prod.yml down        # parar"
echo ""
