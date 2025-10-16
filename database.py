import sqlite3
import secrets
from datetime import datetime
from typing import Optional, List, Dict
import os

DATABASE_FILE = 'api_keys.db'

def get_db():
    """Get database connection"""
    conn = sqlite3.connect(DATABASE_FILE)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initialize database with required tables"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS api_keys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE NOT NULL,
            status TEXT NOT NULL DEFAULT 'inactive',
            player_username TEXT DEFAULT NULL,
            created_at TEXT NOT NULL,
            activated_at TEXT DEFAULT NULL,
            last_used_at TEXT DEFAULT NULL
        )
    ''')
    
    conn.commit()
    conn.close()
    print("✅ Database initialized successfully")

def generate_key() -> str:
    """Generate a unique API key"""
    return secrets.token_urlsafe(32)

def create_new_key() -> Dict:
    """Create a new API key"""
    conn = get_db()
    cursor = conn.cursor()
    
    key = generate_key()
    created_at = datetime.now().isoformat()
    
    cursor.execute(
        'INSERT INTO api_keys (key, status, created_at) VALUES (?, ?, ?)',
        (key, 'inactive', created_at)
    )
    
    conn.commit()
    key_id = cursor.lastrowid
    conn.close()
    
    return {
        'id': key_id,
        'key': key,
        'status': 'inactive',
        'player_username': None,
        'created_at': created_at
    }

def get_all_keys() -> List[Dict]:
    """Get all API keys"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM api_keys ORDER BY created_at DESC')
    rows = cursor.fetchall()
    
    conn.close()
    
    return [dict(row) for row in rows]

def get_key_info(key: str) -> Optional[Dict]:
    """Get information about a specific key"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM api_keys WHERE key = ?', (key,))
    row = cursor.fetchone()
    
    conn.close()
    
    return dict(row) if row else None

def manually_activate_key(key: str, player_username: str) -> Dict:
    """Manually activate a key for a player (admin function)"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Проверяем существует ли ключ
    cursor.execute('SELECT * FROM api_keys WHERE key = ?', (key,))
    row = cursor.fetchone()
    
    if not row:
        conn.close()
        return {'success': False, 'error': 'KEY_NOT_FOUND'}
    
    key_data = dict(row)
    
    # Проверяем не активирован ли ключ другим игроком
    if key_data['player_username'] and key_data['player_username'] != player_username:
        # Удаляем старую привязку (админ может переназначить)
        pass
    
    activated_at = datetime.now().isoformat()
    cursor.execute(
        'UPDATE api_keys SET status = ?, player_username = ?, activated_at = ?, last_used_at = ? WHERE key = ?',
        ('active', player_username, activated_at, activated_at, key)
    )
    
    conn.commit()
    conn.close()
    
    return {'success': True, 'message': 'KEY_MANUALLY_ACTIVATED'}

def activate_key(key: str, player_username: str) -> Dict:
    """Activate a key for a specific player"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM api_keys WHERE key = ?', (key,))
    row = cursor.fetchone()
    
    if not row:
        conn.close()
        return {'success': False, 'error': 'KEY_NOT_FOUND'}
    
    key_data = dict(row)
    
    if key_data['status'] == 'frozen':
        conn.close()
        return {'success': False, 'error': 'KEY_FROZEN'}
    
    if key_data['status'] == 'active':
        if key_data['player_username'] != player_username:
            conn.close()
            return {'success': False, 'error': 'KEY_ALREADY_ACTIVATED'}
        else:
            cursor.execute(
                'UPDATE api_keys SET last_used_at = ? WHERE key = ?',
                (datetime.now().isoformat(), key)
            )
            conn.commit()
            conn.close()
            return {'success': True, 'message': 'KEY_ALREADY_OWNED'}
    
    activated_at = datetime.now().isoformat()
    cursor.execute(
        'UPDATE api_keys SET status = ?, player_username = ?, activated_at = ?, last_used_at = ? WHERE key = ?',
        ('active', player_username, activated_at, activated_at, key)
    )
    
    conn.commit()
    conn.close()
    
    return {'success': True, 'message': 'KEY_ACTIVATED'}

def verify_key(key: str, player_username: str) -> Dict:
    """Verify if a key is valid for a specific player"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT * FROM api_keys WHERE key = ?', (key,))
    row = cursor.fetchone()
    
    if not row:
        conn.close()
        return {'valid': False, 'error': 'KEY_NOT_FOUND'}
    
    key_data = dict(row)
    
    if key_data['status'] == 'frozen':
        conn.close()
        return {'valid': False, 'error': 'KEY_FROZEN'}
    
    if key_data['status'] == 'inactive':
        conn.close()
        return {'valid': False, 'error': 'KEY_NOT_ACTIVATED'}
    
    if key_data['player_username'] != player_username:
        conn.close()
        return {'valid': False, 'error': 'KEY_WRONG_OWNER'}
    
    cursor.execute(
        'UPDATE api_keys SET last_used_at = ? WHERE key = ?',
        (datetime.now().isoformat(), key)
    )
    conn.commit()
    conn.close()
    
    return {'valid': True}

def check_player_key(player_username: str) -> Optional[Dict]:
    """Check if a player already has an active key"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Ищем ключ игрока без учета регистра
    cursor.execute(
        'SELECT key, status FROM api_keys WHERE LOWER(player_username) = LOWER(?) AND status = ?',
        (player_username, 'active')
    )
    row = cursor.fetchone()
    
    if row:
        # Обновляем время последнего использования
        cursor.execute(
            'UPDATE api_keys SET last_used_at = ? WHERE key = ?',
            (datetime.now().isoformat(), row['key'])
        )
        conn.commit()
        conn.close()
        return {'key': row['key'], 'status': row['status']}
    
    conn.close()
    return None

def delete_key(key: str) -> bool:
    """Delete a key"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('DELETE FROM api_keys WHERE key = ?', (key,))
    deleted = cursor.rowcount > 0
    
    conn.commit()
    conn.close()
    
    return deleted

def freeze_key(key: str) -> bool:
    """Freeze (deactivate) a key"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('UPDATE api_keys SET status = ? WHERE key = ?', ('frozen', key))
    updated = cursor.rowcount > 0
    
    conn.commit()
    conn.close()
    
    return updated

def unfreeze_key(key: str) -> bool:
    """Unfreeze a key (set it back to active if it was activated, or inactive if not)"""
    conn = get_db()
    cursor = conn.cursor()
    
    cursor.execute('SELECT player_username FROM api_keys WHERE key = ?', (key,))
    row = cursor.fetchone()
    
    if not row:
        conn.close()
        return False
    
    new_status = 'active' if row['player_username'] else 'inactive'
    cursor.execute('UPDATE api_keys SET status = ? WHERE key = ?', (new_status, key))
    updated = cursor.rowcount > 0
    
    conn.commit()
    conn.close()
    
    return updated

if __name__ == '__main__':
    init_db()
