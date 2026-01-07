// 在 script 标签中添加
        document.addEventListener('DOMContentLoaded', function() {
            // 获取所有导航链接
            const navLinks = document.querySelectorAll('.nav-links a');
            
            const sub_navLinks = document.querySelectorAll('.sub-nav-links a');

            // 为每个链接添加点击事件
            navLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    // 移除所有 active 类
                    navLinks.forEach(l => l.classList.remove('active'));
                    // 为当前点击的链接添加 active 类
                    this.classList.add('active');
                });
            });

            // 为每个子链接添加点击事件
            sub_navLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    // 移除所有 active 类
                    navLinks.forEach(l => l.classList.remove('active'));
                    // 为当前点击的链接添加 active 类
                    this.classList.add('active');
                });
            });

            // 根据当前页面自动激活对应链接
            const currentPage = window.location.pathname.split('/').pop();
            navLinks.forEach(link => {
                if (link.getAttribute('href') === currentPage) {
                    link.classList.add('active');
                }
            });
        });

        