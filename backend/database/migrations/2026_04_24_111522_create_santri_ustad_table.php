<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('santri_ustad', function (Blueprint $table) {
            $table->uuid('id')->primary();

            $table->uuid('santri_id');
            $table->uuid('ustad_id');

            $table->foreign('santri_id')
                ->references('id')
                ->on('santri')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->foreign('ustad_id')
                ->references('id')
                ->on('ustad')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('santri_ustad');
    }
};