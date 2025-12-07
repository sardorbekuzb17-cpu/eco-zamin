/**
 * NotificationService
 * Handles user notifications and error messages
 */
class NotificationService {
    constructor() {
        this.notifications = [];
        this.container = null;
        this.initContainer();
    }

    /**
     * Initialize notification container
     */
    initContainer() {
        if (typeof document === 'undefined') return;

        // Check if container already exists
        this.container = document.getElementById('notification-container');

        if (!this.container) {
            this.container = document.createElement('div');
            this.container.id = 'notification-container';
            this.container.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                max-width: 400px;
            `;
            document.body.appendChild(this.container);
        }
    }

    /**
     * Show notification
     */
    show(message, type = 'info', duration = 5000) {
        if (typeof document === 'undefined') {
            console.log(`[${type.toUpperCase()}] ${message}`);
            return;
        }

        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;

        const icons = {
            success: '✓',
            error: '✕',
            warning: '⚠',
            info: 'ℹ'
        };

        const colors = {
            success: '#10b981',
            error: '#ef4444',
            warning: '#f59e0b',
            info: '#3b82f6'
        };

        notification.style.cssText = `
            background: white;
            border-left: 4px solid ${colors[type] || colors.info};
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease-out;
            font-family: system-ui, -apple-system, sans-serif;
        `;

        notification.innerHTML = `
            <span style="
                font-size: 20px;
                color: ${colors[type] || colors.info};
                font-weight: bold;
            ">${icons[type] || icons.info}</span>
            <span style="
                flex: 1;
                color: #374151;
                font-size: 14px;
            ">${message}</span>
            <button style="
                background: none;
                border: none;
                color: #9ca3af;
                cursor: pointer;
                font-size: 18px;
                padding: 0;
                width: 24px;
                height: 24px;
            " onclick="this.parentElement.remove()">×</button>
        `;

        this.container.appendChild(notification);
        this.notifications.push(notification);

        // Auto remove after duration
        if (duration > 0) {
            setTimeout(() => {
                this.remove(notification);
            }, duration);
        }

        return notification;
    }

    /**
     * Remove notification
     */
    remove(notification) {
        if (notification && notification.parentElement) {
            notification.style.animation = 'slideOut 0.3s ease-out';
            setTimeout(() => {
                notification.remove();
                this.notifications = this.notifications.filter(n => n !== notification);
            }, 300);
        }
    }

    /**
     * Show success notification
     */
    success(message, duration = 5000) {
        return this.show(message, 'success', duration);
    }

    /**
     * Show error notification
     */
    error(message, duration = 7000) {
        return this.show(message, 'error', duration);
    }

    /**
     * Show warning notification
     */
    warning(message, duration = 6000) {
        return this.show(message, 'warning', duration);
    }

    /**
     * Show info notification
     */
    info(message, duration = 5000) {
        return this.show(message, 'info', duration);
    }

    /**
     * Clear all notifications
     */
    clearAll() {
        this.notifications.forEach(notification => {
            notification.remove();
        });
        this.notifications = [];
    }

    /**
     * Show confirmation dialog
     */
    confirm(message, onConfirm, onCancel) {
        if (typeof document === 'undefined') {
            return window.confirm(message);
        }

        const overlay = document.createElement('div');
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 10001;
            display: flex;
            align-items: center;
            justify-content: center;
        `;

        const dialog = document.createElement('div');
        dialog.style.cssText = `
            background: white;
            border-radius: 12px;
            padding: 24px;
            max-width: 400px;
            box-shadow: 0 20px 25px rgba(0, 0, 0, 0.15);
        `;

        dialog.innerHTML = `
            <p style="margin: 0 0 20px 0; color: #374151; font-size: 16px;">${message}</p>
            <div style="display: flex; gap: 12px; justify-content: flex-end;">
                <button id="cancel-btn" style="
                    padding: 8px 16px;
                    border: 1px solid #d1d5db;
                    background: white;
                    border-radius: 6px;
                    cursor: pointer;
                    font-size: 14px;
                ">Bekor qilish</button>
                <button id="confirm-btn" style="
                    padding: 8px 16px;
                    border: none;
                    background: #10b981;
                    color: white;
                    border-radius: 6px;
                    cursor: pointer;
                    font-size: 14px;
                ">Tasdiqlash</button>
            </div>
        `;

        overlay.appendChild(dialog);
        document.body.appendChild(overlay);

        dialog.querySelector('#confirm-btn').onclick = () => {
            overlay.remove();
            if (onConfirm) onConfirm();
        };

        dialog.querySelector('#cancel-btn').onclick = () => {
            overlay.remove();
            if (onCancel) onCancel();
        };

        overlay.onclick = (e) => {
            if (e.target === overlay) {
                overlay.remove();
                if (onCancel) onCancel();
            }
        };
    }
}

// Add CSS animations
if (typeof document !== 'undefined') {
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
}

// Export for Node.js environment (for testing)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NotificationService;
}

// Make available globally in browser
if (typeof window !== 'undefined') {
    window.NotificationService = NotificationService;
    window.showNotification = (message, type, duration) => {
        if (!window.notificationService) {
            window.notificationService = new NotificationService();
        }
        return window.notificationService.show(message, type, duration);
    };
}
