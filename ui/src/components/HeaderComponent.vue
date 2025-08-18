<template>
    <div>
        <div>
            <!-- todo: 替换 logo -->
            <a href="#"><el-image src="/public/vite.svg"></el-image></a>
        </div>
        <div class="title">
            <el-menu default-active="2" class="el-menu-vertical-demo" router>
                <template v-for="value in router.options.routes[0].children" :key="value.path">
                    <el-menu-item v-show="value.meta?.isShow == true" :index="value.path">
                        <el-icon>
                            <component :is="value.meta?.icon"></component>
                        </el-icon>
                        <span>{{ value.meta?.title }}</span>
                    </el-menu-item>
                </template>
            </el-menu>
        </div>
    </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

const router = useRouter();
</script>
  
<style lang="scss" scoped>
.el-image {
    height: 65px;
    width: 180px;
}

.title {
    float: left;
    margin-top: -9.5vh;
    margin-left: 12vw;
    font-size: 18px;
    font-weight: 600;
    color: rgb(64, 160, 255);
    line-height: 2vh;

    ul li {
        float: left;
        list-style: none // margin-right: 2vw
    }
}

.right {
    font-weight: 600;
    float: right;
    margin-right: 3vw;
    margin-top: -6.5vh;
    vertical-align: top;

    .el-button {
        margin-top: -5px;
    }
}
</style>
