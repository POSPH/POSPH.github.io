/* =========================================================
   POS PH PRO — Landing Page interactions
   ========================================================= */

const MEGA_DOWNLOAD_URL = 'https://mega.nz/file/zs4AWapI#IY4FeGkgvTrXER-WfjqkeJKyg1DS0dPJbMrRI87qyfY';

(function () {
    'use strict';

    /* Mobile menu toggle */
    const nav = document.querySelector('.nav');
    const toggle = document.querySelector('.nav__toggle');
    const mobileNav = document.getElementById('mobileNav');

    if (toggle && mobileNav) {
        toggle.addEventListener('click', () => {
            const open = nav.classList.toggle('is-open');
            toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
            mobileNav.hidden = !open;
        });
        // Close on link click (mobile UX)
        mobileNav.querySelectorAll('a').forEach((a) => {
            a.addEventListener('click', () => {
                nav.classList.remove('is-open');
                toggle.setAttribute('aria-expanded', 'false');
                mobileNav.hidden = true;
            });
        });
    }

    /* Free-trial download button — points to MEGA when configured;
       otherwise nudges the user to the contact section. */
    document.querySelectorAll('[data-download="free-trial"]').forEach((el) => {
        el.addEventListener('click', (e) => {
            if (MEGA_DOWNLOAD_URL && MEGA_DOWNLOAD_URL.trim().length > 0) {
                el.setAttribute('href', MEGA_DOWNLOAD_URL);
                el.setAttribute('target', '_blank');
                el.setAttribute('rel', 'noopener');
                // let the browser follow the link
            } else {
                // No download configured yet — scroll to contact and explain.
                e.preventDefault();
                const contact = document.getElementById('contact');
                if (contact) contact.scrollIntoView({ behavior: 'smooth' });
                // Small visual nudge
                el.textContent = 'Coming soon — message us!';
                setTimeout(() => { el.textContent = 'Download free trial'; }, 2400);
            }
        });
    });

    /* Reveal-on-scroll for feature cards & screenshots */
    if ('IntersectionObserver' in window) {
        const io = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-revealed');
                    io.unobserve(entry.target);
                }
            });
        }, { rootMargin: '-40px 0px -40px 0px', threshold: 0.1 });

        document.querySelectorAll('.feature-card, .shots__row, .plan, .contact-card').forEach((el) => {
            el.classList.add('reveal');
            io.observe(el);
        });
    }

    /* Active nav link based on scroll position */
    const sections = ['price', 'features', 'screenshots', 'contact']
        .map((id) => document.getElementById(id))
        .filter(Boolean);
    const navLinks = document.querySelectorAll('.nav__links a');

    if (sections.length && navLinks.length && 'IntersectionObserver' in window) {
        const map = new Map();
        navLinks.forEach((a) => {
            const id = a.getAttribute('href')?.replace('#', '');
            if (id) map.set(id, a);
        });
        const spy = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                const link = map.get(entry.target.id);
                if (!link) return;
                if (entry.isIntersecting) {
                    navLinks.forEach((a) => a.classList.remove('is-active'));
                    link.classList.add('is-active');
                }
            });
        }, { rootMargin: '-50% 0px -50% 0px', threshold: 0 });

        sections.forEach((s) => spy.observe(s));
    }
})();
