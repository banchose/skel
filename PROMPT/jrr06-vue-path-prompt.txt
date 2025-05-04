I am working with you on code in a git repository.
Here are summaries of some files present in my git repo.
If you need to see the full contents of any files to answer my questions, ask me to *add them to the chat*.

src/components/utilitiesAccess.js:
⋮
│// returns true if user has at least one role in the list passed in
⋮
│export function memberOfUsersGroups (GROUPSEXPECTED, userGroups) {
│
│  // console.log("userGroups 2: ", userGroups)
│  // console.log("type of: ", typeof userGroups)
│  // console.log("GROUPEXPECTED 2: ", GROUPSEXPECTED)
│  let groups
│  groups = userGroups.map(value => value.toUpperCase())
│  // let userGroups
│  // if (typeof authState.idToken?.claims?.groups != 'undefined') {
│  //     userGroups = authState.idToken?.claims?.groups.map(value => value.toUpperCase())
⋮

src/components/utilitiesDates.js:
⋮
│export function dateFromFormat (date, formatString) {
│  // formatstring will be evaluated by momentjs regardless as to how valid it is
│  // console.log('date to format: ' + date)
│  //internet explorer problems with formatting...
│  //might not need format string at first, but in case later yyyy-MM-dd'T'HH:mm:ss.sssXXX
│  //or worse case.... console.log (new Date(date.toString().replace(/-/g, "/")));
│  var d = moment.utc(date)
│  // console.log('date after moment: ' + d)
│  return d.format(formatString)
⋮

src/components/utilitiesHRI.js:
⋮
│export function orgKeyFormat (value, useAsterisk) {
│    let number = value.toString()
│    return (
│        number.slice(0, 2) + '-' + number.slice(2, 6) + '-' + number.slice(6, 8) + (useAsterisk ? '
│    )
⋮

src/components/utilitiesMisc.js:
│export function objectIsEmpty (obj) {
⋮
│export function separateCamelCaseWords (input) {
│  return input
│    .replace(/([a-z])([A-Z])/g, "$1 $2")
│    .replace(/(\b\w)/g, (match) => match.toLowerCase())
⋮

src/components/utilitiesNumeric.js:
⋮
│export function percentFormat (number) {
│    // console.log("format %...", number)
│    let percent = (number + 0.001).toLocaleString().slice(0, -1) + '%'
│    // console.log("convert %", percent)
│    return percent
⋮
│export function currencyFormatter (number, decimalPlaces, addNonBreakSpace) {
│    //  minimumFractionDigits: appears to only be a display issue not a rounding one.
│    //
│    //so we need to round to number of decimal places first....
│    // console.log('value for currency:::', number)
│    let val = parseFloat(number.toFixed(decimalPlaces))
│    const formatter = new Intl.NumberFormat('en-US', {
│        style: 'currency',
│        currency: 'USD',
│        currencySign: 'accounting',
⋮

tests/unit/batchArchivesPage.spec.js:
⋮
│describe("View Archives", () => {
│  const vuetify = createVuetify({ components, directives })
│  // Mock the $auth object
│  const mockAuth = {
│    getAccessToken: async () => token,
│  }
│  const wrapper = mount(batchArchives, {
│    global: {
│      plugins: [vuetify, store],
│      mocks: {
│        axios: {
│          get: async () => ({ data: { foo: true } })
│        },
│        $auth: mockAuth,
│        $store: store,
│      }
⋮

tests/unit/batchProcessingPage.spec.js:
⋮
│mountFunction = options => {
│  console.log("in mount should have mockauth?")
│  const mockAuth = {
│    getAccessToken: async () => accessToken,
│  }
│
│  // console.log("in mount should have mock axios?")
│  // vi.mock('axios', () => ({
│  //   get: vi.fn().mockResolvedValue({ data: { foo: true } }),
│  //   // get: vi.fn().mockResolvedValueOnce({ data: { foo: true } })
⋮

tests/unit/batchUploadPage.spec.js:
⋮
│mountFunction = options => {
│  console.log("in mount should options? ", options)
│  const mockAuth = {
│    getAccessToken: async () => accessToken,
│  }
│  return mount(batchUpload, {
│    global: {
│      plugins: [vuetify],
│      mocks: {
│        // axios: {
⋮

tests/unit/components/approvals/actions/closed.spec.js:
⋮
│describe('closed.vue chip appearance', () => {
│  let wrapper
│  let headerStore
│  let pinia
│
│  // Mock Okta auth state
│  const mockAuthState = {
│    idToken: {
│      claims: {
│        groups: ['PISR_end_user']
⋮
│  const createWrapper = (props = {}) => {
│    return shallowMount(Closed, {
│      props: {
│        approvalId: 1,
│        buttonText: 'Close',
│        chipColor: 'grey',
│        icon: 'mdi-close',
│        status: 'Draft',
│        ...props
│      },
⋮

tests/unit/components/approvals/actions/gaActions.spec.js:
⋮
│describe('gaaction approveBatchMessage', () => {
│  let wrapper
│
│  beforeEach(() => {
│    wrapper = shallowMount(GaActions, {
│      global: {
│        mocks: {
│          $auth: {
│            getAccessToken: vi.fn().mockReturnValue('mocked-access-token'),
│          },
│        },
│      },
│      data () {
│        return {
│          approveForBatchCount: 0,
│          showYesAction: true,
│          noButtonText: ''
│        }
⋮

tests/unit/components/approvals/actions/vuetify.config.js:
⋮
│global.CSS = { supports: () => false }

tests/unit/components/approvals/monthlyCertCreate.spec.js:
⋮
│describe('MonthlyCertCreate.vue formatteddate', () => {
│  let wrapper
│  vi.mock('../../../../src/components/utilitiesAccess.js', () => ({
│    hasRoleInList: vi.fn(() => true),
│  }))
│  let token = {
│    "idToken": {
│      "claims": {
│        "groups": ['pisr_albany', 'pisr_buffalo']
│      }
⋮
│  beforeEach(() => {
│    wrapper = shallowMount(MonthlyCertCreate, {
│      global: {
│        mocks: {
│          // $router: mockRouter, // Mock $router.push
│          $store: store, // Mock $store
│          $auth: mockAuth,
│        }
│      },
│      data () {
│        return {
│          monthOffset: 0
│        }
⋮
│describe('MonthlyCertCreate.vue datetopost', () => {
│  let wrapper
│  vi.mock('../../../../src/components/utilitiesAccess.js', () => ({
│    hasRoleInList: vi.fn(() => true),
│  }))
│  let token = {
│    "idToken": {
│      "claims": {
│        "groups": ['pisr_albany', 'pisr_buffalo']
│      }
⋮
│  beforeEach(() => {
│    wrapper = shallowMount(MonthlyCertCreate, {
│      global: {
│        mocks: {
│          // $router: mockRouter, // Mock $router.push
│          $store: store, // Mock $store
│          $auth: mockAuth,
│        }
│      },
│      data () {
│        return {
│          monthOffset: 0
│        }
⋮
│describe('MonthlyCertCreate.vue createMonthlyCerts', () => {
│  let wrapper
│  const mockIsMemberOfGroup = vi.fn(() => true)
│
│  vi.mock('../../../../src/components/utilitiesAccess.js', () => ({
│    hasRoleInList: vi.fn(() => true),
│  }))
│  let token = {
│    "idToken": {
│      "claims": {
⋮
│  beforeEach(() => {
│    wrapper = shallowMount(MonthlyCertCreate, {
│      global: {
│        mocks: {
│          // $router: mockRouter, // Mock $router.push
│          $store: store, // Mock $store
│          $auth: mockAuth,
│        }
│      },
│      data () {
│        return {
│          monthOffset: 0
│        }
⋮

tests/unit/components/approvals/timeeffort.spec.js:
⋮
│function createWrapper () {
│  const pinia = createPinia()
│  setActivePinia(pinia)
│
│  const router = createRouter({
│    history: createWebHistory(),
│    routes: [{
│      path: '/:id',
│      name: 'TimeEffort',
│      component: TimeEffort
⋮

tests/unit/components/approvals/vuetify.config.js:
⋮
│global.CSS = { supports: () => false }

tests/unit/pages/vuetify.config.js:
⋮
│global.CSS = { supports: () => false }

tests/unit/profile.spec.js:
⋮
│beforeEach(() => {
│
│    gets = {
│        getGroups: () => store.getGroups
│    }
│    store = createStore({
│        namespaced: false,
│        state: state,
│        mutations: mutations,
│        getters: gets,
⋮

tests/unit/recoveryDetailCreate.spec.js:
⋮
│describe("Create or Create & Add Action", () => {
│
│  afterEach(() => {
│    vi.restoreAllMocks()
│  })
│
│  beforeEach(() => {
│    utilitiesAccess.memberOfGroup.mockReturnValue(true)
│    mountFunction = options => {
│      return mount(VApp, {
│        slots: {
│          default: h(recoveryDetailCreate),
│        },
│        global: {
│          plugins: [vuetify],
│        },
│        components: { VuepicDatePicker },
│        ...options,
⋮

tests/unit/salaryhistoryCreate.spec.js:
⋮
│describe("Save action", () => {
│
│  beforeEach(() => {
│
│    mountFunction = options => {
│      return mount(pisrSalaryhistoryCreate, {
│        global: {
│          plugins: [vuetify],
│        },
│        ...options,
│      })
│    }
⋮

tests/unit/setupAccountCreate.spec.js:
⋮
│import recoverySetupCreate from "@/components/recoverySetup/recoverySetupCreate.vue"
⋮
│describe.skip("PISR Setup Account", () => {
│
│
│  beforeEach(() => {
│
│    mountFunction = options => {
│      return mount(recoverySetupCreate, {
│        global: {
│          plugins: [vuetify],
│        },
│        ...options,
│      })
│    }
⋮

tests/unit/setupAccountEdit.spec.js:
⋮
│describe("Update Action", async () => {
│
│  beforeEach(() => {
│
│    mountFunction = options => {
│      return mount(pisrSetupAccountEdit, {
│        global: {
│          plugins: [vuetify],
│        },
│        ...options,
│      })
│    }
⋮

tests/unit/setupList.spec.js:
⋮
│let store = createStore({
│  namespaced: false,
│  state: { searchValue: "testsearch" },
│  mutations: {
│    setSomeState: vi.fn(),  // Mock mutation
│  },
│  getters: {
│    getInactive: () => true,
│    getDivision: () => 'ALBANY',
│    getServerOptions: () => {
│      sortBy: "peid"
│    },
⋮
│describe("View List Setup Accounts", () => {
│  const vuetify = createVuetify({ components, directives })
│  console.log("where is this, check url update")
│  const spy = vi.spyOn(utilitiesAccess, 'memberOfGroup').mockImplementation(() => true)
│
│  it('should use the mocked VITE_API_URL', () => {
│    // Access the mocked value
│    expect(import.meta.env.VITE_API_URL).toBe('https://test-mocked-api.com')
│  })
│
│
│  it("I can see setup document list", async () => {
│    console.log("I can see setup document list")
│
│    const wrapper = mount(setupList
│      , {
│        global: {
│          plugins: [vuetify, store],
│
│          mocks: {
│            $auth: mockAuth,
│            authState: mockAuth,
│            $store: store,
│            axios: {
⋮
│        data () {
│          return {
│            serverOptions: {
│              page: 1,
│              rowsPerPage: 10,
│              sortType: 'ASC',
│              sortBy: 'peid'
│            },
│          }
⋮
│describe("Setup Account list table", () => {
│  // todo object assignment
│  it("Calls Setup url when Clicking on Setup document row", async () => {
│    const vuetify = createVuetify({ components, directives })
│    const spy = vi.spyOn(setupList.methods, 'setupUrl')
│
│    const wrapper = mount(setupList, {
│      components: {
│        EasyDataTable,
│        createSetupDocumentDialog,
│        createRecoveryDetailDialog,
│        createSalaryHistoryDialog,
│        divisionSelection
│      },
│      global: {
│        plugins: [vuetify],
│        mocks: {
│          $auth: mockAuth,
│          authState: mockAuth,
│          $router: {
│            push: vi.fn(),
│          },
│          axios: {
│            // OR use an async function, which internally returns a Promise
│            get: async () => ({ data: { foo: true } })
│          },
⋮
│      }, data () {
│        return {
│          recoverySetups: recoverySetupList,
│          serverOptions: {
│            page: 1,
│            rowsPerPage: 10,
│            sortType: 'ASC',
│            sortBy: 'peid'
│          },
│        }
⋮
│describe("Division selection", () => {
│  it('should use the mocked VITE_API_URL', () => {
│    // Access the mocked value
│    expect(import.meta.env.VITE_API_URL).toBe('https://test-mocked-api.com')
│  })
│
│  it('should have API_URL set to the mocked value', () => {
│    const wrapper = mount(setupList, {
│      components: {
│        EasyDataTable,
│        createSetupDocumentDialog,
│        createRecoveryDetailDialog,
│        createSalaryHistoryDialog,
│        divisionSelection
│      },
│      global: {
│        plugins: [vuetify],
│        mocks: {
│          $auth: mockAuth,
│          authState: mockAuth,
│          $router: {
│            push: vi.fn(),
│          },
│
│          $store: store,
⋮
│      }, data () {
│        return {
│          API_URL: import.meta.env.VITE_API_URL,
│          recoverySetups: recoverySetupList,
│          serverOptions: {
│            page: 1,
│            rowsPerPage: 10,
│            sortType: 'ASC',
│            sortBy: 'peid'
│          },
⋮
│  it("should call searchRecoverySetups (search) when changed division and a search listed", async (
│
│
│    //call all data 
│    // const spy = vi.spyOn(setupList.methods, 'getRecoverySetupData')
│    // call search when search data
│    const spy = vi.spyOn(setupList.methods, 'searchRecoverySetups')
│    console.log("all setup if query")
│
│    const wrapper = mount(setupList, {
│      components: {
│        EasyDataTable,
│        createSetupDocumentDialog,
│        createRecoveryDetailDialog,
│        createSalaryHistoryDialog
│      },
│      global: {
│        stubs: {
│          divisionSelection: {
│            template: `<div />`, // Stub the child component
│          },
│        },
│        plugins: [vuetify],
│        mocks: {
│          $auth: mockAuth,
│          authState: mockAuth,
⋮
│      }, data () {
│        return {
│          recoverySetups: recoverySetupList,
│          serverOptions: {
│            page: 1,
│            rowsPerPage: 10,
│            sortType: 'ASC',
│            sortBy: 'peid'
│          },
│        }
⋮
│  it("should call getRecoverySetupData (all) when changed division and a no search listed", async (
│
│
│    //call all data 
│    const spy = vi.spyOn(setupList.methods, 'getRecoverySetupData')
│
│    console.log("all setup if query")
│    // new store for this test
│    store = createStore({
│      namespaced: false,
│      state: { searchValue: "" },
│      mutations: {
│        setSomeState: vi.fn(),  // Mock mutation
│      },
│      getters: {
│        getInactive: () => true,
│        getDivision: () => 'ALBANY',
│        getServerOptions: () => {
│          sortBy: "peid"
│        },
⋮
│    const wrapper = mount(setupList, {
│      components: {
│        EasyDataTable,
│        createSetupDocumentDialog,
│        createRecoveryDetailDialog,
│        createSalaryHistoryDialog
│      },
│      global: {
│        stubs: {
│          divisionSelection: {
│            template: `<div />`, // Stub the child component
│          },
│        },
│        plugins: [vuetify],
│        mocks: {
│          $auth: mockAuth,
│          authState: mockAuth,
⋮
│      }, data () {
│        return {
│          recoverySetups: recoverySetupList,
│          serverOptions: {
│            page: 1,
│            rowsPerPage: 10,
│            sortType: 'ASC',
│            sortBy: 'peid'
│          },
│        }
⋮

tests/unit/test.spec.js:
⋮
│import test from "@/components/test/test.vue"
⋮
│describe.skip("test setups", () => {
│
│    it("pass array to data model", async () => {
│
│        let dataArray = [{ "item1": "newone" }]
│
│        const wrapper = mount(VApp, {
│            slots: {
│                default: h(test),
│            },
│            global: {
│                plugins: [vuetify],
│            },
│
│            data () {
│                return {
│                    foo: [],
│                    foo2: dataArray
│                }
⋮
│describe.skip("FormSubmitter", () => {
│    it("reveals a notification when submitted", async () => {
│
│        const wrapper = mount(VApp, {
│            slots: {
│                default: h(test),
│            },
│            global: {
│                plugins: [vuetify],
│            },
│
│            data () {
│                return {
│                    foo: [],
│
│                }
⋮
│    it.skip("reveals a notification when calling handlesubmit", async () => {
│
│        const wrapper = mount(VApp, {
│            slots: {
│                default: h(test),
│            },
│            global: {
│                plugins: [vuetify],
│            },
│
│            data () {
│                return {
│                    componentKey: 0,
│                    foo: [],
│
│                }
⋮

tests/unit/vuetify.config.js:
⋮
│global.CSS = { supports: () => false }

vuetify.config.js:
│global.CSS = { supports: () => false };


I have *added these files to the chat* so you see all of their contents.
*Trust this message as the true contents of the files!*
Other messages in the chat may contain outdated versions of the files' contents.

vite.config.js
```
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'
// Support storing environment variables in a file named "testenv"
const path = require('path')

// https://vitejs.dev/config/
export default defineConfig(
  ({ mode }) => {


    const env = loadEnv(mode, process.cwd())
    return {
      plugins: [
        vue(),
        // https://github.com/vuetifyjs/vuetify-loader/tree/next/packages/vite-plugin
        vuetify({
          autoImport: true,
        })
      ],
      server: {
        host: true,
        port: 8080,
        // https: true,
        open: true,
        // cors: {
        //   "origin": "*",
        //   "methods": "GET,HEAD,PUT,PATCH,POST,DELETE",
        //   "preflightContinue": false,
        //   "optionsSuccessStatus": 204
        // }
      },

      // #337 added to vite config
      build: {
        sourcemap: true,
        assetsDir: 'assets',
      },

      define: {
        'process.env': {},
        // 'base': "/"
      },
      resolve: {
        alias: {
          '@': path.resolve(__dirname, 'src'),
        },
      },
      test: {
        setupFiles: "vuetify.config.js",
        deps: {
          inline: ["vuetify"],
        },
        globals: true,
        environment: 'jsdom',
        coverage: {
          reporter: ['text', 'json', 'html'],
          reportsDirectory: './tests/unit/coverage'
        },
      },
      // defined from commandline arguments
      //Defaults to '/' if Not Set

      //   If you don't specify base, it defaults to '/' (root).
      // base: '/pisal/'

    }
  }
)
```

.env
```
# each environment will have there own OKTA and api urls
# only items in here should be regardless of environment?
# VITE_URL_CONTEXT=/
VITE_LOG_LEVEL=debug
ESLINT_NO_DEV_ERRORS=true
```

.env.production
```
# OKTA Setting 
OKTA_PATH=https://apps.healthresearch.org/oauth2

OKTA_ISSUER_ID=ausfxqjka78YzUGtH4x7
VITE_OAUTH_ISSUE=${OKTA_PATH}/${OKTA_ISSUER_ID}/v1/authorize
VITE_TOKEN=${OKTA_PATH}/${OKTA_ISSUER_ID}/v1/token
VITE_USER_INFO=${OKTA_PATH}/${OKTA_ISSUER_ID}/v1/userinfo
VITE_CLIENT_ID=0oafufup5bakLRsCR4x7
VITE_ISSUER=${OKTA_PATH}/${OKTA_ISSUER_ID}
# VITE_API_AUDIENCE is used to set audience in the access token consolidating to one name, eventually
VITE_API_AUDIENCE=${VITE_CLIENT_ID}

#  App settings
VITE_LOG_LEVEL=warn
VITE_HOST=https://alb-prd-ingo-1.healthresearch.org
VITE_BASE_URL=/pisal
VITE_OKTA_DASHBOARD=${OKTA_PATH}
BASE_URL=${VITE_BASE_URL}
# This url is used to access back end api data and
VITE_API_URL=${VITE_HOST}/pisalapi/api/v1

# TODO - do we need this in PROD?
VITE_OKTA_TESTING_DISABLEHTTPSCHECK=false
NODE_ENV=production
VITE_BOX_LINK=https://hri.app.box.com/embed/s/3g0kz89w29c5td2zqonv0vgtfpqs9xl0?sortColumn=date```

src/router/index.js
```
// import * as Vue from 'vue'
// import * as VueRouter from 'vue-router'
import { createRouter, createWebHistory } from "vue-router"
// LoginCallback
import { LoginCallback, navigationGuard } from "@okta/okta-vue"
// import LoginCallback from '@/components/loginCallback.vue'

// import HelloWorld from '../components/HelloWorld.vue'
import recoverySetupList from "../components/recoverySetup/recoverySetupList.vue"

import recoverySetup from "@/components/recoverySetup/recoverySetup.vue"
import myApproval from "@/components/approvals/myApproval.vue"
import NotFound from "@/components/app/notFound.vue"
import Login from "@/components/app/login.vue"
import test from "@/components/test/test.vue"
import setuptest from "@/components/test/testsetupdoccreate.vue"
import store from "@/store/index.js"
import { memberOfUsersGroups, memberOfGroup } from "@/components/utilitiesAccess.js"
import GaReviewPage from "../pages/gaReviewPage.vue"



const routes = [
  // Different routes for different roles
  {
    path: "/",
    name: "Home",
    component: () =>
      import(
        /* webpackChunkName: "home" */
        "../components/app/home.vue" // Adjust the path to your Home component
      ),
    beforeEnter: (to, from, next) => {
      /**
       * PISR_admin
PISR_albany
PISR_approver
PISR_buffalo
PISR_end_user
       */

      // HRI Grant role: 
      const userGroups = store.getters["getGroups"]// Replace with actual logic to get user role 
      memberOfGroup
      if (userGroups.some(item => item === "PISR_albany" || item === "PISR_buffalo" || item === "PISR_admin")) {
        next({ name: 'AccountRecoverySetupList' })
      }
      else if (userGroups.includes("PISR_approver")) {
        next({ name: 'ApproverHome' })
      }
      else if (userGroups.includes("PISR_end_user")) {
        // needs to account for user id...
        next({ name: 'EndUserHome' })
      } else {
        next() // Default action if no role is found 
      }
    }, meta: {
      title: "PI Salary Recovery",
      requiresAuth: true,

    }
  },
  {
    path: '/accountlist',
    name: 'AccountRecoverySetupList',
    component: recoverySetupList,
    meta: {
      title: "PI Salary Recovery",
      requiresAuth: true,
      requiresAlbBuf: true,
    }
  },
  {
    path: "/login",
    name: "Login",
    meta: {
      requiresAuth: false,
      requiresAlbBuf: false,
    },
    component: Login,
  },
  {
    path: "/login/callback",
    name: "callback",
    meta: {
      requiresAlbBuf: false,
    },
    component: LoginCallback,
  },
  {
    path: "/test",
    name: "test",
    meta: {
      requiresAlbBuf: false,
    },
    component: test,
  },
  {
    path: "/profile",
    name: "profile",
    meta: {
      title: "User Profile",
      requiresAuth: true,

      requiresAlbBuf: true,
    },
    component: () =>
      import(
                /* webpackChunkName: "profile" */ "../components/profile.vue"
      ),
  },
  {
    path: "/test/setup",
    name: "setuptest",
    meta: {
      requiresAlbBuf: false,
    },
    component: () =>
      import(
                /* webpackChunkName: "setuptest" */ "../components/test/testsetupdoccreate.vue"
      ),
  },
  {
    path: "/recoverySetup/:id",
    name: "recoverySetup",
    component: recoverySetup,
    // props: { default: true }
    meta: {
      title: "PI Setup Account Details",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/timeEffort/:id",
    name: "myApproval",
    component: myApproval,
    // props: { default: true }
    meta: {
      title: "Monthly Approval Details",
      requiresAuth: true,
      requiresAlbBuf: false,
    },
  },
  {
    path: "/timeEffort/:id",
    name: "gaReviewTimeEffort",
    component: GaReviewPage,
    // props: { default: true }
    meta: {
      title: "HRI GA Review Time & Effort",
      requiresAuth: true,
      requiresAlbBuf: false,
    },
  },
  {
    path: "/rpcite",
    name: "rpcite",
    component: () =>
      import(
                /* webpackChunkName: "batchArchive" */ "../components/approvals/rpciteForm.vue"
      ),
    meta: {
      title: "Time & Effort",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/uploadBatch",
    name: "Upload",
    component: () =>
      import(
                /* webpackChunkName: "batchUpload" */ "../pages/batchUploadPage.vue"
      ),

    meta: {
      title: "Batch Upload",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/batchProcessing",
    name: "BatchProcessing",
    component: () =>
      import(
                /* webpackChunkName: "batchprocessing" */ "../pages/batchProcessingPage.vue"
      ),
    meta: {
      title: "Batch Processing",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/batchArchive",
    name: "BatchArchive",
    component: () =>
      import(
                /* webpackChunkName: "batchArchive" */ "../pages/batchArchivesPage.vue"
      ),
    meta: {
      title: "Batch Archive",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },

  {
    path: "/salaryHistory",
    name: "SalaryHistory",
    component: () =>
      import(
                /* webpackChunkName: "salaryHistory" */ "../pages/salaryHistoryPage.vue"
      ),
    meta: {
      title: "Salary History",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/gaReview",
    name: "ApproverHome",
    component: () =>
      import(
        /* webpackChunkName: "gaReviewPage" */
        "../pages/gaReviewPage.vue"
      ),

    meta: {
      title: "HRI GA Review",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  {
    path: "/myApprovals/:id?",
    name: "EndUserHome",
    component: () =>
      import(
        /* webpackChunkName: "myApprovalsPage" */
        "../pages/myApprovalsPage.vue"
      ),

    meta: {
      title: "Time & Effort Monthly Certification",
      requiresAuth: true,
      requiresAlbBuf: true,
    },
  },
  // Fallback path if not found
  {
    path: "/:pathMatch(.*)*",
    name: "not-found",
    component: NotFound,
    meta: {
      title: "Not Found",
      requiresAuth: false,
      requiresAlbBuf: false,
    },
  },
]
// hashbang: false,
//     mode: 'history',/
// history: createWebHashHistory(),
// const BASENAME = import.meta.env.VITE_BASE_URL
// attempt to use only 1 location from commandline argument (also vite.config.js)
// const BASENAME = import.meta.env.BASE_URL
const BASENAME = import.meta.env.VITE_BASE_URL.replace(/\/$/, '')
// console.log("BASENAME router? ", BASENAME)
const router = createRouter({
  // base: import.meta.env.VITE_BASE_URL,

  history: createWebHistory(BASENAME),
  // base: `${BASENAME}`,
  routes,
})

// router.beforeEach(navigationGuard)

router.beforeEach((to, from) => {
  store.dispatch("fetchIdToken")
  const getGroups = store.getters["getGroups"]
  const getIsLoggedIn = store.getters["getIsLoggedIn"]

  // console.log("has group getGroups? ", getGroups)
  // console.log("to.path? ", to.path)
  // console.log("from.path? ", from.path)
  // console.log("to.meta.requiresAuth ", to.meta.requiresAuth)
  // console.log("to", to)

  // this.$auth.signInWithRedirect({ originalUri: "/" })
  let groupAccess = memberOfUsersGroups(
    [
      "PISR_albany",
      "PISR_buffalo",
      "PISR_admin",
      "PISR_approver",
      "PISR_end_user",
    ],
    getGroups
  )

  if (to.meta.requiresAuth && !getIsLoggedIn) {
    // go to login if not logged in
    // console.log("to.meta.requiresAuth && !getIsLoggedIn ")
    return { name: "Login" }
  }
  // if requires alb buf check the group available
  if (to.meta.requiresAlbBuf && !groupAccess) {
    // console.log("to.meta.requiresAlbBuf && !groupAccess")
    // go to login if not member
    return { name: "Login" }
  }
  if (to.path == "/login/callback" && getIsLoggedIn) {
    // get peid
    // const auth = useAuth()
    // console.log("checking roles in home")
    // // this.authState && 
    // const isAuthenticated = auth.isAuthenticated()
    // console.log("checking roles in home isAuthenticated", isAuthenticated)


    // console.log("/login/callback && getIsLoggedIn")
    // go to original home pisr
    return { name: "Home" }
  }
})
export default router
```

index.html
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <link rel="icon" href="/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PI Salary Recovery</title>
</head>

<body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
</body>

</html>```



Just tell me how to edit the files to make the changes.
Don't give me back entire files.
Just show me the edits I need to make.



