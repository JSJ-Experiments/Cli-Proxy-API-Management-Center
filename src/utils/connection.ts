import { DEFAULT_API_PORT, MANAGEMENT_API_PREFIX } from './constants';

export const normalizeApiBase = (input: string): string => {
  let base = (input || '').trim();
  if (!base) return '';
  base = base.replace(/\/+$/i, '');
  base = base.replace(/\/v8\/management$/i, '');
  if (!/^https?:\/\//i.test(base)) {
    base = `http://${base}`;
  }
  return base;
};

export const computeApiUrl = (base: string): string => {
  const normalized = normalizeApiBase(base);
  if (!normalized) return '';
  return `${normalized}${MANAGEMENT_API_PREFIX}`;
};

export const detectDeploymentPrefix = (pathname: string): string => {
  const path = (pathname || '').trim();
  if (!path || path === '/') return '';

  if (/\/management\.html\/?$/i.test(path)) {
    return path.replace(/\/management\.html\/?$/i, '').replace(/\/+$/g, '');
  }

  return '';
};

export const detectApiBaseFromLocation = (): string => {
  try {
    const { protocol, hostname, port, pathname } = window.location;
    const normalizedPort = port ? `:${port}` : '';
    const deploymentPrefix = detectDeploymentPrefix(pathname);
    return normalizeApiBase(
      `${protocol}//${hostname}${normalizedPort}${deploymentPrefix}`
    );
  } catch (error) {
    console.warn('Failed to detect api base from location, fallback to default', error);
    return normalizeApiBase(`http://localhost:${DEFAULT_API_PORT}`);
  }
};
