<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('santri', function (Blueprint $table) {
            $table->string('fcm_token')->nullable()->after('role');
        });

        Schema::table('ustad', function (Blueprint $table) {
            $table->string('fcm_token')->nullable()->after('role');
        });
    }

    public function down(): void
    {
        Schema::table('santri', fn($t) => $t->dropColumn('fcm_token'));
        Schema::table('ustad',  fn($t) => $t->dropColumn('fcm_token'));
    }
};
