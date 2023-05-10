const mastodonAccounts = new Map();

export async function getAccount(handle) {
    if (!isValidHandle(handle))
        return null;

    const cachedMastodonAccount = mastodonAccounts.get(handle);
    if (cachedMastodonAccount) {
        return cachedMastodonAccount;
    }
    const {instance} = splitHandle(handle);
    let accountArray = []
    try {
        const ret = await getJson(instance, "/api/v2/search", {q: handle, type: "accounts", limit: 1});
        accountArray = ret.accounts || [];
    } catch (e) {
        console.error(`Error getting public account for ${handle}, trying local`, e);
    }

    if (accountArray.length < 1 && MASTODON_INSTANCE) {
        try {
            const ret = await getJson(MASTODON_INSTANCE.split('://').slice(-1)[0], "/api/v2/search", {q: handle, type: "accounts", limit: 1});
            accountArray = ret.accounts || [];
            if( accountArray.length >= 1 ) {
                const account = accountArray[0];
                let instance = account.url.split('/@')[0].split('://').slice(-1)[0];
                const ret = await getJson(instance, "/api/v2/search", {q: handle, type: "accounts", limit: 1});
                accountArray = ret.accounts || [];
            }
        } catch (e) {
            console.error(`Error getting public account for ${handle}, trying local`, e);
        }
    }

    if (accountArray.length >= 1) {
        const account = accountArray[0];
        cacheMastodonAccount(handle, account);
        return account;
    } else {
        console.error(`No account found for ${handle}`)
        return null;
    }
}

export async function getPosts(accountInfo) {
    let instance = accountInfo.url.split('/@')[0].split('://').slice(-1)[0];
    console.assert(accountInfo.handle, accountInfo);
    const [pinnedPosts, posts] = await Promise.all([
        getJson(instance, `/api/v1/accounts/${accountInfo.id}/statuses`, {pinned: true}),
        getJson(instance, `/api/v1/accounts/${accountInfo.id}/statuses`, {exclude_replies: true}),
    ]);
    let allPosts = posts;
    if (pinnedPosts && pinnedPosts.length) {
        const pinnedIds = new Set();
        pinnedPosts.forEach(post => {
            pinnedIds.add(post.id);
            post.pinned = true
        })
        allPosts = pinnedPosts.concat(posts.filter(post => !pinnedIds.has(post.id)))
    }
    return allPosts;
}

export async function getUserInfo() {
    let handle = getUserHandle();
    if (handle == null)
        return {}
    let account = await getAccount(handle);
    account.handle = handle;
    return account;
}

export function isLoggedIn() {
    let handle = getUserHandle();
    return handle != null;
}

export function getUserHandle() {
    const cookies = document.cookie.split(';');
    for (let i = 0; i < cookies.length; i++) {
        const cookie = cookies[i].trim();
        if (cookie.startsWith('loggedIn=')) {
            return decodeURIComponent(cookie.split('=')[1]);
        }
    }
    return null;
}

export function cleanServerName(serverText) {
    const trimmed = serverText.trim();
    if (trimmed.startsWith("http")) {
        return new URL(trimmed).hostname;
    }
    if (trimmed.indexOf("@") !== -1) {
        const match = trimmed.match(/[^@]+$/)
        return match[0];
    }
    return trimmed;
}

function isValidHandle(handle) {
    let mastodonHandleRGEX = /@?\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b/gmi;
    return mastodonHandleRGEX.test(handle);
}

function splitHandle(handle) {
    const a = handle.split("@");
    return {userName: a[a.length - 2], instance: a[a.length - 1]}
}

function cacheMastodonAccount(handle, account) {
    let instance = account.url.split('/@')[0].split('://').slice(-1)[0];
    account.handle = handle;
    account.instance = instance;
    mastodonAccounts.set(handle, account);
}

async function getJson(instance, path, params) {
    const queryString = params ? "?" + new URLSearchParams(params).toString() : "";
    const headers = {"Content-Type": "application/json"};
    if (path.startsWith("/")) {
        path = path.substring(1);
    }

    const url = `https://${instance}/${path}${queryString}`
    const res = await fetch(url, {
        headers: headers
    });
    if (!res.ok) {
        throw new Error(`${res.code}: Error fetching ${path}`)
    }
    return await res.json();
}