#!/bin/bash

# Script de prueba para verificar la captura de leads del bot
# Este script simula la interacción del bot y verifica que los leads se guarden en la DB

echo "🧪 PRUEBA DE CAPTURA DE LEADS - B.A.I. BOT"
echo "=========================================="
echo ""

# Configuración
API_URL="http://localhost:8000"
CLIENT_ID="ad-meliora"
SESSION_ID="test_$(date +%s)_$(openssl rand -hex 4)"

echo "📋 Configuración:"
echo "   API URL: $API_URL"
echo "   Client ID: $CLIENT_ID"
echo "   Session ID: $SESSION_ID"
echo ""

# Paso 1: Mensaje inicial
echo "1️⃣ Enviando mensaje inicial al bot..."
INITIAL_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/chat/message" \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"Hola, quiero información, contactadme\",
    \"client_id\": \"$CLIENT_ID\",
    \"origin\": \"widget\",
    \"platform\": \"widget\",
    \"session_id\": \"$SESSION_ID\"
  }")

echo "   Respuesta: $(echo $INITIAL_RESPONSE | jq -r '.response // .message // "Sin respuesta"')"
echo ""

# Paso 2: Proporcionar email (simulando cuando el bot lo pide)
echo "2️⃣ Enviando email de contacto..."
EMAIL_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/chat/message" \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"prueba_admin@test.com\",
    \"client_id\": \"$CLIENT_ID\",
    \"origin\": \"widget\",
    \"platform\": \"widget\",
    \"session_id\": \"$SESSION_ID\"
  }")

echo "   Respuesta: $(echo $EMAIL_RESPONSE | jq -r '.response // .message // "Sin respuesta"')"
echo ""

# Paso 3: Proporcionar teléfono (opcional)
echo "3️⃣ Enviando teléfono de contacto..."
PHONE_RESPONSE=$(curl -s -X POST "$API_URL/api/v1/chat/message" \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"+34600123456\",
    \"client_id\": \"$CLIENT_ID\",
    \"origin\": \"widget\",
    \"platform\": \"widget\",
    \"session_id\": \"$SESSION_ID\"
  }")

echo "   Respuesta: $(echo $PHONE_RESPONSE | jq -r '.response // .message // "Sin respuesta"')"
echo ""

# Esperar un momento para que el backend procese
echo "⏳ Esperando 3 segundos para que el backend procese el lead..."
sleep 3
echo ""

# Verificar en la base de datos
echo "4️⃣ Verificando en la base de datos..."
cd /Users/hecgsk/Desktop/BAI
DB_RESULT=$(docker compose exec -T db psql -U bai_user -d bai_db -c "SELECT email, phone, status, created_at FROM lead WHERE email = 'prueba_admin@test.com' ORDER BY created_at DESC LIMIT 1;")

echo "$DB_RESULT"
echo ""

# Verificar si se encontró el lead
if echo "$DB_RESULT" | grep -q "prueba_admin@test.com"; then
    echo "✅ ¡ÉXITO! El lead se ha guardado correctamente en la base de datos."
    echo ""
    echo "📊 Últimos 5 leads en la tabla:"
    docker compose exec -T db psql -U bai_user -d bai_db -c "SELECT email, phone, status, created_at FROM lead ORDER BY created_at DESC LIMIT 5;"
else
    echo "❌ ERROR: El lead NO se encontró en la base de datos."
    echo ""
    echo "🔍 Verificando todos los leads:"
    docker compose exec -T db psql -U bai_user -d bai_db -c "SELECT email, phone, status, created_at FROM lead ORDER BY created_at DESC LIMIT 10;"
    echo ""
    echo "⚠️  Posibles causas:"
    echo "   1. El bot no está detectando email/teléfono correctamente"
    echo "   2. El endpoint de creación de leads no se está llamando"
    echo "   3. Hay un error en el backend al guardar el lead"
    echo "   4. El user_id requerido no existe"
fi

echo ""
echo "✅ Prueba completada"


